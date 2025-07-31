import 'dart:async';

import 'package:digi_xpense/core/comman/widgets/accountDistribution.dart';
import 'package:digi_xpense/core/comman/widgets/button.dart';
import 'package:digi_xpense/core/comman/widgets/multiselectDropdown.dart';
import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';
import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/main.dart';
import 'package:flutter/material.dart';
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
  bool _showPaidForError = false;
  bool _showPaidWithError = false;
  //  bool cashAdvanceField = false;
  bool _showQuantityError = false;
  bool _showUnitAmountError = false;
  bool _showUnitError = false;
  bool _showProjectError = false;
  bool setQuality = true;
  bool allowMultSelect = false;

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

  final List<String> _titles = ["Payment Info", "Itemize", "Expense Details"];
  @override
  void initState() {
    super.initState();
    // controller.clearFormFields();

    controller.selectedDate ??= DateTime.now();

    // controller.fetchPaidto();

    itemizeControllers.add(Controller());
    controller.configuration();
    controller.isManualEntryMerchant = false;
    _initializeUnits();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Safe to update observables here
      controller.fetchPaidto();
      controller.fetchPaidwith();
      controller.fetchProjectName();
      controller.fetchTaxGroup();
      controller.fetchUnit();
      controller.currencyDropDown();
      controller.getUserPref();
      controller.fetchExpenseCategory();
      _loadSettings();
      loadAndAppendCashAdvanceList();
      // controller.fetchExchangeRate();
    });
  }

  Future<void> loadAndAppendCashAdvanceList() async {
    try {
      final newItems = await controller.fetchCashAdvanceList();
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
      if (controller.cashAdvanceIds.text.isEmpty) {
        cashAdvanceField.value = 'Please select a Cash Advance';
        isValid = false;
      }
      else {
      setState(() {
        // selectReferenceIDError = null;
        cashAdvanceField.value= null;
      });
    }
    } else {
      cashAdvanceField.value = 'Please select a Cash Advance';
      // isValid = false;
    }
    if (controller.paidWith == null) {
      print("PaidWithError");
      setState(() {
        paidwithError.value = 'Please select a Payment Method';
      });
      isValid = false;
    } else {
      setState(() {
        paidwithError.value = null;
      });
    }

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
      lastDate: DateTime(2100),
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

  Widget _buildItemizeCircles() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _itemizeCount,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedItemizeIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedItemizeIndex = index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isSelected ? Colors.orange : Colors.grey,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Itemize',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool validateExpenseForm() {
    bool isValid = true;

    setState(() {
      // Reset all error states
      _showQuantityError = false;
      _showUnitAmountError = false;
      _showUnitError = false;
      _showTaxAmountError = false;
      _showPaidForError = false;
    });

    // Validate Paid For (category)
    if (controller.selectedCategoryId.isEmpty) {
      _showPaidForError = true;
      isValid = false;
    }

    // Validate Tax Amount if mandatory
    final taxAmountMandatory = controller.configList.any(
      (f) => f['FieldName'] == 'Tax Amount' && f['IsMandatory'] == true,
    );
    if (taxAmountMandatory && controller.taxAmount.text.trim().isEmpty) {
      _showTaxAmountError = true;
      isValid = false;
    }

    // Validate Itemized fields if enabled
    if (_itemizeCount > 1) {
      if (controller.quantity.text.trim().isEmpty) {
        _showQuantityError = true;
        isValid = false;
      }

      if (controller.unitAmount.text.trim().isEmpty) {
        _showUnitAmountError = true;
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
    return DefaultTabController(
      length: _itemizeCount,
      initialIndex: _selectedItemizeIndex,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            onTap: (index) {
              setState(() {
                _selectedItemizeIndex = index;
              });
            },
            tabs: List.generate(
              _itemizeCount,
              (index) => Tab(text: "Itemize ${index + 1}"),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              children: List.generate(
                _itemizeCount,
                (index) => Center(
                    child:
                        expenseCreateForm2(context, itemizeControllers[index])),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormPage(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return
        // ignore: deprecated_member_use
        WillPopScope(
            onWillPop: () async {
              controller.clearFormFields();

              return true; // allow back navigation
            },
            child: Scaffold(
              appBar: AppBar(
                  title: const Text(
                "Cash Advance Return Form ",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )),
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
                        const CreateExpensePage(),
                      ],
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    if (_currentStep == 2)
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
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        label: const Text(
                          'Back',
                          style: TextStyle(color: Colors.black),
                        ),
                      )
                    else
                      const SizedBox(), // Empty space if back is not shown
                  ],
                ),
              ),
            ));
  }

  Widget expenseCreateForm2(BuildContext context, Controller controller) {
    // Use the provided controller parameter consistently
    controller.selectedunit ??= controllerItems.selectedunit;
    controller.selectedDate = controllerItems.selectedDate;
    // controller.isReimbursite.vale = true;
    print("selecteduni${controller.selectedunit}");
    if (setQuality) {
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ...controllerItems.configList
            .where((field) =>
                field['IsEnabled'] == true &&
                field['FieldName'] != 'Location' &&
                field['FieldName'] != 'Refrence Id' &&
                field['FieldName'] != 'Is Billable' &&
                field['FieldName'] != 'is Reimbursible')
            .map((field) {
          final String label = field['FieldName'];
          final bool isMandatory = field['IsMandatory'] ?? false;

          Widget inputField;

          if (label == 'Project Id') {
            inputField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchableMultiColumnDropdownField<Project>(
                  labelText: 'Project Id ${isMandatory ? "*" : ""}',
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
                        _showProjectError = false;
                      }
                    });
                    controller.fetchExpenseCategory();
                  },
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
                                color: Colors.blue, // highlight search matches
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
                          Expanded(child: highlight(proj.name)),
                          Expanded(child: highlight(proj.code)),
                        ],
                      ),
                    );
                  },
                ),
                if (_showProjectError) // 👈 Show error below dropdown
                  const Padding(
                    padding: EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      'Please select a Project',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            );
          } else if (label == 'Tax Group') {
            inputField = SearchableMultiColumnDropdownField<TaxGroupModel>(
              labelText: 'Tax Group ${isMandatory ? "*" : ""}',
              columnHeaders: const ['Tax Group', 'Tax ID'],
              items: controllerItems.taxGroup,
              selectedValue: controller.selectedTax,
              searchValue: (tax) => '${tax.taxGroup} ${tax.taxGroupId}',
              displayText: (tax) => tax.taxGroupId,
              validator: (tax) => isMandatory && tax == null
                  ? 'Please select a Tax Group'
                  : null,
              onChanged: (tax) {
                setState(() {
                  controller.selectedTax = tax;
                  controllerItems.selectedTax = tax;
                });
              },
              rowBuilder: (tax, searchQuery) {
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

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(child: highlight(tax.taxGroup)),
                      Expanded(child: highlight(tax.taxGroupId)),
                    ],
                  ),
                );
              },
            );
          } else if (label == 'Tax Amount') {
            inputField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  keyboardType: TextInputType.number,
                  controller: controller.taxAmount,
                  style: const TextStyle(color: Colors.black),
                  onChanged: (tax) {
                    setState(() {
                      controller.taxAmount.text = tax;
                      // Clear error once the user starts typing
                      if (tax.isNotEmpty) {
                        _showTaxAmountError = false;
                      }
                    });
                  },
                  decoration: InputDecoration(
                    labelText: '$label${isMandatory ? " *" : ""}',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                if (_showTaxAmountError) // 👈 Show error only when flag is true
                  const Padding(
                    padding: EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      'Tax Amount is required',
                      style: TextStyle(color: Colors.red, fontSize: 12),
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
        }).toList(),
        const SizedBox(height: 16),
        const Text("Paid For *"),
        const SizedBox(height: 20),
        if (_showPaidForError)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Please select a category',
              style: TextStyle(color: Colors.red, fontSize: 12),
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
                labelText: 'Unit *',
                columnHeaders: const ['Uom Id', 'Uom Name'],
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
            if (showItemizeDetails)
              Row(
                children: [
                  Expanded(
                      child: TextField(
                    keyboardType: TextInputType.number,
                    controller: controller.unitAmount,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (value) {
                      controllerItems.fetchExchangeRate();
                      controllerItems.unitAmount.text = value;
                      setState(() {
                        controller.unitAmount.text = value;
                        _showUnitAmountError = false;
                      });
                      final qty =
                          double.tryParse(controller.quantity.text) ?? 0.0;
                      final unit =
                          double.tryParse(controller.unitAmount.text) ?? 0.0;

                      final calculatedLineAmount = qty * unit;

                      controller.paidAmount.text =
                          calculatedLineAmount.toStringAsFixed(2);
                      controllerItems.paidAmontIsEditable.value = false;
                      controller.lineAmount.text =
                          calculatedLineAmount.toStringAsFixed(2);
                      controller.lineAmountINR.text =
                          calculatedLineAmount.toStringAsFixed(2);
                    },
                    onEditingComplete: () {
                      String text = controller.unitAmount.text;
                      double? value = double.tryParse(text);
                      if (value != null) {
                        controller.unitAmount.text = value.toStringAsFixed(2);
                        controller.paidAmount.text = value.toStringAsFixed(2);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: "Unit Amount *",
                      errorText: _showUnitAmountError
                          ? 'Unit Amount is required'
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )),
                  if (showItemizeDetails) const SizedBox(width: 12),
                  if (showItemizeDetails)
                    Expanded(
                        child: TextField(
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      controller: controller.quantity,
                      style: const TextStyle(color: Colors.black),
                      onChanged: (value) {
                        setState(() {
                          controller.quantity.text = value;
                          _showQuantityError = false;
                          setQuality = false;
                        });
                        final qty =
                            double.tryParse(controller.quantity.text) ?? 0.0;
                        final unit =
                            double.tryParse(controller.unitAmount.text) ?? 0.0;

                        final calculatedLineAmount = qty * unit;
                        print(
                            "calculatedLineAmount: $qty x $unit = $calculatedLineAmount");
                        controller.paidAmount.text =
                            calculatedLineAmount.toStringAsFixed(2);
                        controller.paidAmontIsEditable.value = false;
                        controller.lineAmount.text =
                            calculatedLineAmount.toStringAsFixed(2);
                        controller.lineAmountINR.text =
                            calculatedLineAmount.toStringAsFixed(2);
                      },
                      decoration: InputDecoration(
                        labelText: "Quantity*",
                        errorText:
                            _showQuantityError ? 'Quantity is required' : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    )),
                ],
              ),
            if (showItemizeDetails) const SizedBox(height: 16),
            if (showItemizeDetails)
              Row(
                children: [
                  Expanded(
                      child: _buildTextInput(
                          "Line Amount *", controller.lineAmount,
                          enabled: false)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildTextInput(
                          "Line Amount in INR *", controller.lineAmountINR,
                          enabled: false)),
                ],
              ),
            if (controller.lineAmount.text.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      final double lineAmount =
                          double.tryParse(controller.lineAmount.text) ?? 0.0;

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
                        controller.split
                            .add(AccountingSplit(percentage: 100.0));
                      }

                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
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
                              splits: controller.split,
                              lineAmount: lineAmount,
                              onChanged: (i, updatedSplit) {
                                if (!mounted) return;
                                controller.split[i] = updatedSplit;
                              },
                              onDistributionChanged: (newList) {
                                if (!mounted) return;
                                controller.accountingDistributions.clear();
                                controller.accountingDistributions
                                    .addAll(newList);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Text('Account Distribution'),
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
                    const Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _calculateTotalLineAmount(controller).toStringAsFixed(2),
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
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: "Comments",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 2),
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
                    onPressed: () => _removeItemize(_selectedItemizeIndex),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.gradientEnd),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.delete,
                        color: Color.fromARGB(255, 233, 8, 8)),
                    label: const Text(
                      "Remove",
                      style: TextStyle(color: AppColors.gradientEnd),
                    ),
                  ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _addItemize,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.gradientEnd),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.add, color: AppColors.gradientEnd),
                  label: const Text(
                    'Itemize',
                    style: TextStyle(color: AppColors.gradientEnd),
                  ),
                ),
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
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      label: const Text(
                        'Back',
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                  else
                    const SizedBox(),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      // Reset error states
                      setState(() {
                        _showQuantityError = false;
                        _showUnitAmountError = false;
                        _showUnitError = false;
                        _showTaxAmountError = false;
                      });

                      bool isValid = true;

                      if (controller.selectedCategoryId.isEmpty) {
                        setState(() => _showPaidForError = true);
                        isValid = false;
                      }
                      if (_itemizeCount > 1) {
                        if (controller.quantity.text.isEmpty) {
                          setState(() => _showQuantityError = true);
                          isValid = false;
                        }

                        if (controller.unitAmount.text.isEmpty) {
                          setState(() => _showUnitAmountError = true);
                          isValid = false;
                        }

                        if (controller.selectedunit == null) {
                          setState(() => _showUnitError = true);
                          isValid = false;
                        }
                      }
                      final taxAmountMandatory = isFieldMandatory('Tax Amount');
                      // Validate other mandatory fields
                      if (controller.taxAmount.text.isEmpty &&
                          taxAmountMandatory) {
                        setState(() => _showTaxAmountError = true);
                        isValid = false;
                      }
                      // Validate Project Id if mandatory
                      final projectIdMandatory = isFieldMandatory('Project Id');

                      print("projectIdMandatory$projectIdMandatory");
                      print(
                          "projectIdMandatory${controller.selectedProject == null}");
                      if (projectIdMandatory &&
                          controller.selectedProject == null) {
                        setState(() => _showProjectError = true);
                        isValid = false;
                      } else {
                        setState(() => _showProjectError = false);
                      }

                      print('isValid$isValid');
                      print('isValid${itemizeControllers.length}');
                      if (isValid) {
                        controllerItems.finalItems = itemizeControllers
                            .map((c) => c.toExpenseItemModel())
                            .toList();
                        _nextStep();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.gradientEnd,
                      side: const BorderSide(color: AppColors.gradientEnd),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _currentStep == 2 ? 'Finish' : 'Next',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ]),
    )));
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

    Widget _buildIcon(String? icon) {
      const fallbackUrl =
          "https://icons.veryicon.com/png/o/commerce-shopping/icon-of-lvshan-valley-mobile-terminal/home-category.png";

      try {
        if (icon != null && icon.isNotEmpty) {
          if (icon.startsWith('data:image')) {
            // Data URI: extract base64 part
            final base64Str = icon.split(',').last;
            Uint8List bytes = base64Decode(base64Str);
            return Image.memory(
              bytes,
              width: 30,
              height: 30,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported, size: 30),
            );
          } else if (RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(icon)) {
            // Plain base64 (no prefix)
            Uint8List bytes = base64Decode(icon);
            return Image.memory(
              bytes,
              width: 30,
              height: 30,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported, size: 30),
            );
          } else {
            // URL case
            return Image.asset(
              icon,
              width: 30,
              height: 30,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported, size: 30),
            );
          }
        }
      } catch (_) {
        // Invalid base64 or broken URL
      }

      // Fallback image
      return Image.network(
        fallbackUrl,
        width: 30,
        height: 30,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_not_supported, size: 30),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
        });
        _showPaidForError = false;
        controllers.selectedCategoryId = item.categoryId;
        controller.selectedCategoryId = item.categoryId;

        print("Tapped Category Name: ${item.categoryName}");
        print("Tapped Category ID: ${controllers.selectedCategoryId}");

        // // Optionally store or process them
        // selectedCategoryName = item.categoryName;
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(icon),
            const SizedBox(height: 8),
            Text(
              item.categoryId,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            filled: !enabled ? true : false,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
                            return 'Please select a request date';
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
                                    labelText: 'Request Date *',
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
                                            ? 'Select date'
                                            : DateFormat('dd/MM/yyyy').format(
                                                controller.selectedDate!),
                                        style: TextStyle(
                                          color: controller.selectedDate == null
                                              ? Colors.grey
                                              : Colors.black,
                                        ),
                                      ),
                                      const Icon(Icons.calendar_today,
                                          size: 20),
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
                              .where((field) =>
                                  field['IsEnabled'] == true &&
                                  field['FieldName'] == 'Refrence Id')
                              .map((field) {
                            final String label = field['FieldName'];
                            final bool isMandatory =
                                field['IsMandatory'] ?? false;
                            isThereReferenceID = field['IsMandatory'] ?? false;
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
                                          controller: controller.referenceID,
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
                                              errorText: field.errorText),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                if (selectReferenceIDError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, bottom: 8),
                                    child: Text(
                                      selectReferenceIDError.toString(),
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                              ],
                            );
                          }).toList(),
                        );
                      }),

                      // const SizedBox(height: 10),

                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MultiSelectMultiColumnDropdownField<
                                CashAdvanceDropDownModel>(
                              labelText: 'Cash Advance Request',
                              items: controller.cashAdvanceListDropDown,
                              isMultiSelect: allowMultSelect ?? false,
                              selectedValue: controller.singleSelectedItem,
                              selectedValues: controller.multiSelectedItems,
                              // selectedValue: controller.selectedLocation,
                              // enabled: controller.isEditModePerdiem,
                              // controller: controller.locationController,
                              // ignore: unnecessary_string_interpolations
                              searchValue: (proj) => '${proj.cashAdvanceReqId}',
                              displayText: (proj) => proj.cashAdvanceReqId,
                              validator: (proj) => proj == null
                                  ? 'Please select a CashAdvance Field'
                                  : null,
                              onChanged: (item) {
                              cashAdvanceField.value = null;
                              },
                              onMultiChanged: (items) {
                              
                              },
                              columnHeaders: const [
                                'Request ID',
                                'Request Date'
                              ],
                              rowBuilder: (proj, searchQuery) {
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
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                        TextSpan(
                                          text: text.substring(start, end),
                                          style: const TextStyle(
                                            color: Colors.black,
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
                                          child: Text(proj.cashAdvanceReqId)),
                                      Expanded(
                                          child: Text(
                                              proj.requestDate.toString())),
                                    ],
                                  ),
                                );
                              },
                            ),
                            if (selectReferenceIDError != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, bottom: 8),
                                child: Text(
                                  selectReferenceIDError.toString(),
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            if (cashAdvanceField.value != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, bottom: 8),
                                child: Text(
                                  cashAdvanceField.value!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                          ]),
                      const SizedBox(height: 14),
                      const Text(
                        'Paid With',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // Paid With Radio Buttons
                      Obx(() {
                        if (controller.paidWith == null &&
                            controller.paymentMethods.isNotEmpty) {
                          controller.paidWith =
                              controller.paymentMethods.first.paymentMethodId;
                          controller.paymentMethodeID =
                              controller.paymentMethods.first.paymentMethodId;
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Payment methods list
                            ...List.generate(controller.paymentMethods.length,
                                (index) {
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
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
                                      Icon(icons[index % icons.length],
                                          color: Colors.black),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          method.paymentMethodName,
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                  value: method.paymentMethodId,
                                  groupValue: controller.paidWith,  
                                  onChanged: (String? value) {
                                    controller.paymentMethodeID = value;
                                    setState(() {
                                      controller.paidWith = value;
                                    });
                                    // paidwithError.value =
                                    //     null; // Clear error on selection
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
                                      duration:
                                          const Duration(milliseconds: 300),
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
                                icon: const Icon(Icons.arrow_back,
                                    color: Colors.black),
                                label: const Text(
                                  'Back',
                                  style: TextStyle(color: Colors.black),
                                ),
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
                                    color: AppColors.gradientEnd),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                _currentStep == 2 ? 'Finish' : 'Next',
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
  const CreateExpensePage({super.key});

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
                      child: const Icon(Icons.zoom_in),
                      backgroundColor: Colors.deepPurple,
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: "zoom_out_$index",
                      onPressed: _zoomOut,
                      child: const Icon(Icons.zoom_out),
                      backgroundColor: Colors.deepPurple,
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
          onTap: () => _pickImage(ImageSource.gallery),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(() {
              // if (controller.isLoading.value) {
              //   return const Center(child: CircularProgressIndicator());
              // } else
              if (controller.imageFiles.isEmpty) {
                return const Center(child: Text('Tap to Upload Document(s)'));
              } else {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.imageFiles.length,
                  itemBuilder: (context, index) {
                    final file = controller.imageFiles[index];
                    return GestureDetector(
                      onTap: () => _showFullImage(file, index),
                      child: Container(
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
  @override
  Widget build(BuildContext context) {
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
                      label: const Text("Upload"),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Capture"),
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
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Paid amount is required';
                              }
                              final parsed = double.tryParse(value);
                              if (parsed == null || parsed <= 0) {
                                return 'Enter a valid amount';
                              }
                              return null;
                            },
                            onChanged: (_) {
                              final paid =
                                  double.tryParse(controller.paidAmount.text) ??
                                      0.0;
                              final rate =
                                  double.tryParse(controller.unitRate.text);
                              if (rate != null) {
                                final result = paid * rate;
                                controller.amountINR.text =
                                    result.toStringAsFixed(2);
                                controller.isVisible.value = true;
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Obx(() {
                            return SearchableMultiColumnDropdownField<Currency>(
                              alignLeft: -90,
                              dropdownWidth: 280,
                              labelText: "Currency *",
                              columnHeaders: const ['Code', 'Name', 'Symbol'],
                              items: controller.currencies,
                              selectedValue: controller.selectedCurrency.value,
                              backgroundColor:
                                  const Color.fromARGB(255, 22, 2, 92),
                              searchValue: (c) =>
                                  '${c.code} ${c.name} ${c.symbol}',
                              displayText: (c) => c.code,
                              inputDecoration: const InputDecoration(
                                suffixIcon:
                                    Icon(Icons.arrow_drop_down_outlined),
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
                                  c == null ? 'Please select a currency' : null,
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
                                      vertical: 12, horizontal: 16),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(c.code)),
                                      Expanded(child: Text(c.name)),
                                      Expanded(child: Text(c.symbol)),
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
                            controller: controller.unitRate,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Rate *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Rate is required';
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
                              controller.amountINR.text =
                                  result.toStringAsFixed(2);
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
                                    final double lineAmount = double.tryParse(
                                            controller.paidAmount.text) ??
                                        0.0;
                                    if (controller.split.isEmpty &&
                                        controller.accountingDistributions
                                            .isNotEmpty) {
                                      controller.split.assignAll(
                                        controller.accountingDistributions
                                            .map((e) {
                                          return AccountingSplit(
                                            paidFor: e!.dimensionValueId,
                                            percentage: e.allocationFactor,
                                            amount: e.transAmount,
                                          );
                                        }).toList(),
                                      );
                                    } else if (controller.split.isEmpty) {
                                      controller.split.add(
                                          AccountingSplit(percentage: 100.0));
                                    }
                                    print(lineAmount);
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
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
                                                    "  TransAmount: ${dist.transAmount}");
                                                print(
                                                    "  ReportAmount: ${dist.reportAmount}");
                                                print(
                                                    "  AllocationFactor: ${dist.allocationFactor}");
                                                print(
                                                    "  DimensionValueId: ${dist.dimensionValueId}");
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
                                  child: const Text('Account Distribution'),
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
                      decoration: const InputDecoration(
                        labelText: 'Amount in INR *',
                        filled: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Policy Violations
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Policy Violations',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Check Policies',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildPolicyCard(),
                    const SizedBox(height: 40),

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
                                            await controller
                                                .createcashAdvanceReturn(
                                                    context, true, false);
                                          } finally {
                                            controller.setButtonLoading(
                                                'submit', false);
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Please fill all required fields.'),
                                              backgroundColor: Colors.redAccent,
                                            ),
                                          );
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
                                    : const Text(
                                        'Submit',
                                        style: TextStyle(
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
                                                    .createcashAdvanceReturn(
                                                        context, false, false);
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
                                      backgroundColor:
                                          const Color.fromARGB(241, 20, 94, 2),
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
                                        : const Text("Save"),
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
                                        : const Text(
                                            "Cancel",
                                            style: TextStyle(
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Policy 1001', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.check, color: Colors.green),
              SizedBox(width: 8),
              Expanded(child: Text("Expense Amount Under Limit")),
            ],
          ),
          SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.check, color: Colors.green),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Receipt Required Amount: Any expense recorded should have a receipt",
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.close, color: Colors.red),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "If description has been made mandatory by the Admin for all expense",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "An expense that has expired is considered a Policy",
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
