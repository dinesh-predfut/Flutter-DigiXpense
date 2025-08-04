import 'dart:convert';
import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/pages/ApprovalHub/ApprovalPages/hubMileage/hubMileage_1.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/Mileage/mileageExpenseFormstart.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;

import '../../../core/comman/widgets/searchDropown.dart';
import '../../../core/constant/Parames/params.dart';
import '../screen/ALl_Expense_Screens/GeneralExpense/viewGeneralExpense.dart';
import '../screen/ALl_Expense_Screens/Pending Approval/approvalPendingEdit.dart';
import '../screen/ALl_Expense_Screens/PerDiem/perDiemCreateform.dart';
import '../screen/ALl_Expense_Screens/cashAdvanceReturn/viewCashAdvanceReturn.dart';
import 'ApprovalPages/hubMileageStepPage.dart';
import 'ApprovalPages/hubcashAdvanceReturn.dart';
import 'ApprovalPages/hubgeneralExpense.dart';
import 'ApprovalPages/hubperDiem.dart';

// Main Dynamic Page
class ApprovalHubPage extends StatefulWidget {
  const ApprovalHubPage({super.key});

  @override
  State<ApprovalHubPage> createState() => _ApprovalHubPageState();
}

class _ApprovalHubPageState extends State<ApprovalHubPage> {
  late Future<Map<String, dynamic>> futureData;
  bool showCancelIcon = false;
  bool isFutureReady = false;
  final controller = Get.put(Controller());
  RxString titleName = ''.obs;
  String selectedType = '';
  FilterItem? selectedField;
  String fieldValue = '';

  // Simulated data for searchable dropdowns
  List<String> types = ['Expense', 'Cash Advance Retrun'];
  List<FilterItem> fields = [
    FilterItem(id: 'MerchantId', label: 'Expense Id'),
    FilterItem(id: '2', label: 'Project id'),
   
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loadSkippedItems();
    });
  }

  Future<void> loadSkippedItems() async {
    final storage = await controller.prefs;
    final items = storage.getStringList('skippedWorkItems');

    if (items != null && items.isNotEmpty) {
      controller.skippedWorkItems.addAll(items.map((e) => int.parse(e)));
      controller.showSkipButton.value = controller.skippedWorkItems.isEmpty;

      // ✅ Still call fetchApprovalData even with skipped items
      futureData =
          controller.fetchApprovalData(controller.skippedWorkItems.toList());

      setState(() {
        isFutureReady = true;
        showCancelIcon = true;
      });
    } else {
      futureData =
          controller.fetchApprovalData([]); // ✅ empty list if no skipped items

      setState(() {
        isFutureReady = true;
        showCancelIcon = false;
      });
    }
  }

  Widget _getExpenseWidget(String type, Map<String, dynamic> data) {
    switch (type.trim()) {
      case "General Expenses":
        // titleName = "General Expenses";

        return HubApprovalViewEditExpensePage(
          items: GESpeficExpense.fromJson(data),
          isReadOnly: false,
        );
      case "PerDiem":
        // titleName = "PerDiem";

        return HubCreatePerDiemPage(
          item: PerdiemResponseModel.fromJson(data),
          isReadOnly: false,
        );
      case "Mileage":
        // titleName = "Mileage";

        return HubMileageStepForm(
          mileageId: ExpenseModelMileage.fromJson(data),
        );
      case "CashAdvanceReturn":
        // titleName = "Cash Advance Request";

        return HubApprovalViewEditCashAdvanceReturnPage(
          items: GESpeficExpense.fromJson(data),
          isReadOnly: false,
        );
      default:
        return const Center(child: Text("Unsupported Expense Type"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          controller.clearFormFields();
          controller.isEnable.value = false;
          controller.isLoadingGE1.value = false;
          Navigator.pushNamed(context, AppRoutes.dashboard_Main);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 11, 1, 61),
            elevation: 0,
            leading: const BackButton(color: Colors.white),
            title: Obx(
              () => Flexible(
                child: Text(
                  "Approval Hub ${titleName.value}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon:
                    const Icon(Icons.filter_alt_outlined, color: Colors.white),
                onPressed: showFilterPopup,
              ),
              if (showCancelIcon)
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: () async {
                    try {
                      await controller.clearSkippedItems(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  },
                ),
            ],
          ),
          body: !isFutureReady
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<Map<String, dynamic>>(
                  future: futureData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      print("Error: ${snapshot.error}");
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final data = snapshot.data!;
                      final rawType = data['ExpenseType'] ?? '';
                      final expenseType = rawType.toString().trim();
                      print("Fetched ExpenseType: '$expenseType'");
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (titleName.value != expenseType) {
                          titleName.value = expenseType;
                        }
                      });

                      return _getExpenseWidget(expenseType, data);
                    } else {
                      print("No data or unexpected format: ${snapshot.data}");
                      return const Center(
                        child: Text("No data available or unexpected format"),
                      );
                    }
                  },
                ),
        ));
  }

  void showFilterPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          decoration:  const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 26, 3, 90),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,  color: Color.fromARGB(255, 26, 3, 90),),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: Color.fromARGB(255, 12, 12, 12), height: 20),

              // General Settings Section
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'General Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 2, 9, 99),
                  ),
                ),
              ),

              // Type Dropdown
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      
                      ),
                      // contentPadding:
                      //     EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      filled: false,
                    ),
                    value: types.contains(selectedType) ? selectedType : null,
                    onChanged: (String? value) {
                      setState(() {
                        selectedType = value!;
                      });
                    },
                    items: types.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(
                          type,
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    style: const TextStyle(color: Colors.black),
                    dropdownColor: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Field Searchable Dropdown
              Container(
                decoration: BoxDecoration(
                   color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SearchableMultiColumnDropdownField<FilterItem>(
                  labelText: 'Field',
                  items: fields,
                  selectedValue: selectedField,
                  columnHeaders: const [],
                  searchValue: (p) => p.label,
                  displayText: (p) => p.label,
                  onChanged: (value) {
                    setState(() {
                      selectedField = value!;
                    });
                  },
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
                          Expanded(child: highlight(p.label)),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Value Input Field
              Container(
                decoration: BoxDecoration(
                   color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Value *',
                    hintText: 'Eg: EXP001',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide:
                          BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                    
                    filled: false,
                  ),
                  onChanged: (value) {
                    setState(() {
                      fieldValue = value;
                    });
                  },
                ),
              ),

              // Action Buttons
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedType.isNotEmpty && fieldValue.isNotEmpty) {
                        // Apply filter logic here
                        print(
                            'Applied Filter: Type=$selectedType, Field=$selectedField, Value=$fieldValue');
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all required fields.'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color.fromARGB(255, 11, 1, 61),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class SearchableDropdown<T> extends StatefulWidget {
  final String label;
  final List<T> items;
  final T? value;
  final Function(T?) onChanged;
  final String searchHint;
  final Widget Function(T) itemBuilder;

  const SearchableDropdown({
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.searchHint,
    required this.itemBuilder,
  });

  @override
  _SearchableDropdownState<T> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  String _searchQuery = '';
  TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.items.where((item) {
      final itemText = widget.itemBuilder(item).toString().toLowerCase();
      return itemText.contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.searchHint,
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: widget.value,
          onChanged: widget.onChanged,
          items: filteredItems.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: widget.itemBuilder(item),
            );
          }).toList(),
        ),
      ],
    );
  }
}
