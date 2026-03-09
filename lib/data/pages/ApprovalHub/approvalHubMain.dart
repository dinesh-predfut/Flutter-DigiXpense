import 'dart:convert';
import 'package:diginexa/core/constant/url.dart';
import 'package:diginexa/data/models.dart';
import 'package:diginexa/data/pages/API_Service/apiService.dart';
import 'package:diginexa/data/pages/ApprovalHub/ApprovalPages/externalApproval.dart';
import 'package:diginexa/data/pages/ApprovalHub/ApprovalPages/hubLeave.dart';
import 'package:diginexa/data/pages/ApprovalHub/ApprovalPages/hubMileage/hubMileage_1.dart';
import 'package:diginexa/data/pages/screen/ALl_Expense_Screens/Mileage/mileageExpenseFormstart.dart';
import 'package:diginexa/data/pages/screen/widget/router/router.dart';
import 'package:diginexa/data/service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:diginexa/core/comman/widgets/pageLoaders.dart';
import 'package:http/http.dart';
import '../../../core/comman/widgets/searchDropown.dart';
import '../../../core/constant/Parames/params.dart';
import '../../../l10n/app_localizations.dart';
import '../screen/ALl_Expense_Screens/GeneralExpense/viewGeneralExpense.dart';
import '../screen/ALl_Expense_Screens/Pending Approval/approvalPendingEdit.dart';
import '../screen/ALl_Expense_Screens/PerDiem/perDiemCreateform.dart';
import '../screen/ALl_Expense_Screens/cashAdvanceReturn/viewCashAdvanceReturn.dart';
import 'ApprovalPages/hubMileageStepPage.dart';
import 'ApprovalPages/hubcashAdvanceReturn.dart';
import 'ApprovalPages/hubgeneralExpense.dart';
import 'ApprovalPages/hubperDiem.dart';

// Model for Filter Field
class FilterItem {
  final String id;
  final String label;
  final String type; // 'text', 'number', 'boolean'

  FilterItem({required this.id, required this.label, this.type = 'text'});
}

// Main Dynamic Page
class ApprovalHubPage extends StatefulWidget {
  const ApprovalHubPage({super.key});

  @override
  State<ApprovalHubPage> createState() => _ApprovalHubPageState();
}

class _ApprovalHubPageState extends State<ApprovalHubPage> {
  Future<Map<String, dynamic>>? futureData;
  bool showCancelIcon = false;
  bool isFutureReady = false;
  final controller = Get.find<Controller>();

  // Filter Selections
  String selectedType = '';
  FilterItem? selectedField;
  String fieldValue = '';
  FilterItem? selectedFieldExternal;
  // Define types and fields with types
  List<String> types = [
    'Expense',
    'CashAdvance',
    'Leave',
    'TimeSheet',
    'External',
  ];
  Map<String, List<FilterItem>> fieldsByType = {
    'Expense': [
      FilterItem(id: 'ExpenseId', label: 'Expense Id', type: 'text'),
      FilterItem(id: 'ProjectId', label: 'Project Id', type: 'text'),
      FilterItem(id: 'PaymentMethod', label: 'Payment Method', type: 'text'),
      FilterItem(
        id: 'TotalAmountTrans',
        label: 'Total Amount (Transaction)',
        type: 'number',
      ),
      FilterItem(
        id: 'TotalAmountReporting',
        label: 'Total Amount (Reporting)',
        type: 'number',
      ),
      FilterItem(
        id: 'ExpenseCategoryId',
        label: 'Expense Category Id',
        type: 'text',
      ),
      FilterItem(
        id: 'ExpenseCategoryName',
        label: 'Expense Category',
        type: 'text',
      ),
      FilterItem(id: 'MerchantName', label: 'Merchant Name', type: 'text'),
      FilterItem(
        id: 'IsReimbursable',
        label: 'Is Reimbursable',
        type: 'boolean',
      ),
      FilterItem(id: 'CurrencyCode', label: 'Currency Code', type: 'text'),
      FilterItem(
        id: 'TransactionDate',
        label: 'Transaction Date',
        type: 'date',
      ),
      FilterItem(id: 'SubmissionDate', label: 'Submission Date', type: 'date'),
      FilterItem(id: 'Country', label: 'Country', type: 'text'),
      FilterItem(id: 'City', label: 'City', type: 'text'),
      FilterItem(id: 'Department', label: 'Department', type: 'text'),
      FilterItem(id: 'EmployeeId', label: 'Employee Id', type: 'text'),
      FilterItem(id: 'Status', label: 'Status', type: 'text'),
      FilterItem(
        id: 'ReceiptAttached',
        label: 'Receipt Attached',
        type: 'boolean',
      ),
      FilterItem(id: 'Description', label: 'Description', type: 'text'),
      FilterItem(
        id: 'ApprovedAmount',
        label: 'Approved Amount',
        type: 'number',
      ),
      FilterItem(id: 'VendorId', label: 'Vendor Id', type: 'text'),
      FilterItem(id: 'CostCenter', label: 'Cost Center', type: 'text'),
    ],
    'CashAdvance': [
      FilterItem(id: 'ReturnId', label: 'Return Id', type: 'text'),
      FilterItem(id: 'CashAdvanceId', label: 'Cash Advance Id', type: 'text'),
      FilterItem(id: 'EmployeeId', label: 'Employee Id', type: 'text'),
      FilterItem(id: 'Amount', label: 'Return Amount', type: 'number'),
      FilterItem(id: 'CurrencyCode', label: 'Currency Code', type: 'text'),
      FilterItem(id: 'ReturnDate', label: 'Return Date', type: 'date'),
      FilterItem(id: 'SubmittedDate', label: 'Submitted Date', type: 'date'),
      FilterItem(
        id: 'Status',
        label: 'Status',
        type: 'text',
      ), // e.g., Pending, Approved, Rejected
      FilterItem(id: 'Description', label: 'Description', type: 'text'),
      FilterItem(id: 'ApprovedBy', label: 'Approved By', type: 'text'),
      FilterItem(id: 'Department', label: 'Department', type: 'text'),
      FilterItem(id: 'ProjectId', label: 'Project Id', type: 'text'),
      FilterItem(
        id: 'ReceiptSubmitted',
        label: 'Receipt Submitted',
        type: 'boolean',
      ),
      FilterItem(id: 'ExchangeRate', label: 'Exchange Rate', type: 'number'),
      FilterItem(id: 'Notes', label: 'Notes', type: 'text'),
    ],
    'Leave': [
      FilterItem(id: 'LeaveId', label: 'Leave Id', type: 'text'),
      FilterItem(id: 'ApplicationDate', label: 'ApplicationDate', type: 'date'),
      FilterItem(id: 'LeaveCode', label: 'Leave Code', type: 'text'),
      FilterItem(id: 'EmployeeId', label: 'Employee Id', type: 'number'),
      FilterItem(id: 'EmployeeName', label: 'Employee Name', type: 'text'),
      FilterItem(id: 'FromDate', label: 'From Date', type: 'date'),
      FilterItem(id: 'ToDate', label: 'To Date', type: 'date'),
      FilterItem(
        id: 'ReasonForLeave',
        label: 'Reason For Leave',
        type: 'text',
      ), // e.g., Pending, Approved, Rejected
      FilterItem(id: 'Reliever', label: 'Reliever', type: 'text'),
      FilterItem(id: 'ProjectId', label: 'Project Id', type: 'text'),
      FilterItem(id: 'NotifyHR', label: 'Notify HR', type: 'boolean'),
      FilterItem(
        id: 'NotifyTeamMembers',
        label: 'Notify Team Members',
        type: 'boolean',
      ),
      FilterItem(
        id: 'NotifyingUserIds',
        label: 'Notifying User Ids',
        type: 'text',
      ),
      FilterItem(
        id: 'OutOfOfficeMessage',
        label: 'Out Of Office Message',
        type: 'text',
      ),
      FilterItem(id: 'IsPaidLeave', label: 'Is Paid Leave', type: 'boolean'),
      FilterItem(
        id: 'EmergencyContactNumber',
        label: 'Emergency ContactNumber',
        type: 'number',
      ),
      FilterItem(id: 'LeaveLocation', label: 'Leave Location', type: 'text'),
      FilterItem(id: 'Duration', label: 'Duration', type: 'number'),
      FilterItem(id: 'LeaveBalance', label: 'Leave Balance', type: 'number'),
    ],
    'TimeSheet': [
      FilterItem(id: 'TimesheetId', label: 'Timesheet Id', type: 'text'),
      FilterItem(
        id: 'ApplicationDate',
        label: 'Application Date',
        type: 'date',
      ),
      FilterItem(id: 'EmployeeId', label: 'Employee Id', type: 'number'),
      FilterItem(id: 'EmployeeName', label: 'Employee Name', type: 'text'),
      FilterItem(id: 'Frequency', label: 'Frequency', type: 'text'),
      FilterItem(id: 'FromDate', label: 'From Date', type: 'date'),
      FilterItem(id: 'ToDate', label: 'To Date', type: 'date'),
      FilterItem(id: 'FromDate', label: 'From Date', type: 'date'),
      FilterItem(id: 'ToDate', label: 'To Date', type: 'date'),
      FilterItem(id: 'ProjectId', label: 'Project Id', type: 'text'),
      FilterItem(id: 'CaptureMethod', label: 'Capture Method', type: 'text'),
      FilterItem(id: 'Source', label: 'Source', type: 'text'),
      FilterItem(
        id: 'TimesheetStatus',
        label: 'Timesheet Status',
        type: 'text',
      ),
      FilterItem(id: 'CreatedUser', label: 'Created User', type: 'text'),
    ],
    'External': [
      FilterItem(id: 'DocumentType', label: 'Document Type', type: 'DropDown'),
    ],
  };
  var externalFields = <FilterItem>[].obs;

  Future<void> loadExternalFields() async {
    final response = await ApiService.get(
      Uri.parse(
        '${Urls.baseURL}/api/v1/masters/approvalmanagement/workflowapproval/externalapproval/documenttype?page=1&sort_order=asc&choosen_fields=Name%2CDescription',
      ),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      List<FilterItem> tempList = data.map((e) {
        return FilterItem(
          id: e['Name'] ?? '',
          label: e['Name'] ?? '',
          type: 'text',
        );
      }).toList();
      externalFields.assignAll(tempList);
    } else {
      throw Exception("Failed to load External Document Types");
    }
  }

  // Boolean options
  final List<String> booleanOptions = ['True', 'False'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadSkippedItems();
      loadExternalFields();
    });
  }

  Future<void> loadSkippedItems() async {
    print("its calling ");
    final storage = await controller.prefs;
    final items = storage.getStringList('skippedWorkItems');

    final skippedList =
        items?.map((e) => double.tryParse(e)?.toInt() ?? 0).toList() ?? [];

    controller.skippedWorkItems.clear();
    if (skippedList.isNotEmpty) {
      controller.skippedWorkItems.addAll(skippedList);
    }
    controller.showSkipButton.value = controller.skippedWorkItems.isEmpty;

    futureData = controller.fetchApprovalData(skippedList, '');

    setState(() {
      isFutureReady = true;
      showCancelIcon = skippedList.isNotEmpty;
    });
  }

  Widget _getExpenseWidget(String type, Map<String, dynamic> data) {
    switch (type.trim()) {
      case "General Expenses":
        return HubApprovalViewEditExpensePage(
          items: GESpeficExpense.fromJson(data),
          isReadOnly: false,
        );
      case "PerDiem":
        return HubCreatePerDiemPage(
          item: PerdiemResponseModel.fromJson(data),
          isReadOnly: false,
        );
      case "Mileage":
        return HubMileageStepForm(
          mileageId: ExpenseModelMileage.fromJson(data),
        );
      case "CashAdvanceReturn":
        return HubApprovalViewEditCashAdvanceReturnPage(
          items: GESpeficExpense.fromJson(data),
          isReadOnly: false,
        );
      case "Leave":
        return ApprovalHubViewEditLeavePage(
          leaveRequest: LeaveDetailsModel.fromJson(data),
          isReadOnly: false,
          status: false,
        );
      default:
        return const Center(child: Text("Unsupported Expense Type"));
    }
  }

  String getLocalizedTitle(BuildContext context, String? titleName) {
    final loc = AppLocalizations.of(context)!;
    switch (titleName) {
      case "General Expenses":
        return loc.generalExpense;
      case "CashAdvanceReturn":
        return loc.cashAdvanceReturn;
      case "PerDiem":
        return loc.perDiem;
      case "Mileage":
        return loc.mileage;
      case "External Approval":
        return "External Approval";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.clearFormFields();
        controller.closeField();
        controller.isEnable.value = false;
        controller.isLoadingGE1.value = false;
        Navigator.pushNamed(context, AppRoutes.dashboard_Main);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          // backgroundColor: const Color.fromARGB(255, 11, 1, 61),
          elevation: 0,
          leading: const BackButton(color: Colors.white),
          title: Obx(
            () => Row(
              children: [
                Expanded(
                  child: Text(
                    "${AppLocalizations.of(context)!.approvalHub} ${getLocalizedTitle(context, controller.titleName?.value)}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible, // avoids overflow
                  ),
                ),
              ],
            ),
          ),

          actions: [
            IconButton(
              icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
              onPressed: showFilterPopup,
            ),
            if (showCancelIcon)
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.white),
                onPressed: () async {
                  try {
                    await controller.clearSkippedItems(context);
                    setState(() {
                      showCancelIcon = false;
                    });
                    // Reload data after clearing
                    futureData = controller.fetchApprovalData([], '');
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
            ? const Center(child: SkeletonLoaderPage())
            : FutureBuilder<Map<String, dynamic>>(
                future: futureData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: SkeletonLoaderPage());
                  }

                  if (snapshot.hasError) {
                    print("datadata$snapshot");
                    return const ExternalApprovalMetadataPage();
                  }

                  if (snapshot.hasData) {
                    final data = snapshot.data ?? {};

                    // if (data.isEmpty) {
                    //   return const ExternalApprovalMetadataPage();
                    // }

                    final rawType = data['ExpenseType'] ?? '';
                    final expenseType = rawType.toString().trim();

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (controller.titleName?.value != expenseType) {
                        controller.titleName?.value = expenseType;
                      }
                    });

                    return _getExpenseWidget(expenseType, data);
                  }

                  return const Center(
                    child: Text("No data available or unexpected format"),
                  );
                },
              ),
      ),
    );
  }

  void showFilterPopup() {
    FilterItem? localSelectedField = selectedField;
    String localSelectedType = selectedType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              decoration: const BoxDecoration(
                // color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.filterations,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            controller.closeField();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                  ),

                  // Content Padding
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 12,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Title
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            AppLocalizations.of(context)!.generalSettings,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 🔹 Type - Searchable Dropdown
                        _buildLabel(AppLocalizations.of(context)!.type),
                        SearchableMultiColumnDropdownField<String>(
                          labelText: '',
                          items: types, // List of String
                          selectedValue: localSelectedType,
                          columnHeaders: const ["Select Types"],
                          searchValue: (type) => type, // Used for searching
                          displayText: (type) => type,
                          onChanged: (String? newValue) {
                            setStateModal(() {
                              localSelectedType = newValue!;
                              localSelectedField = null;
                              controller.localFieldValue = '';
                            });
                          },
                          rowBuilder: (item, query) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [Expanded(child: Text(item))],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // 🔹 Field Dropdown
                        _buildLabel(AppLocalizations.of(context)!.field),
                        SearchableMultiColumnDropdownField<FilterItem>(
                          labelText: '',
                          items: fieldsByType[localSelectedType] ?? [],
                          selectedValue: localSelectedField,
                          columnHeaders: const ["Select Value"],
                          searchValue: (item) => item.label,
                          displayText: (item) => item?.label ?? '',
                          onChanged: (value) {
                            setStateModal(() {
                              localSelectedField = value;
                              controller.localFieldValue = '';
                            });
                          },
                          rowBuilder: (item, query) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [Expanded(child: Text(item.label))],
                              ),
                            );
                          },

                          // modalBarrierColor: Colors.black.withOpacity(0.3),
                          // modalBottomSheetOptions: const ModalBottomSheetOptions(
                          //   backgroundColor: Colors.transparent,
                          //   clipBehavior: Clip.none,
                          // ),
                          // dropdownHeight: 300,
                          // dropdownBorderRadius: 12,
                          // dropdownElevation: 4,
                          dropdownMaxHeight: 300,
                        ),

                        const SizedBox(height: 16),

                        // 🔹 Value Input (Dynamic)
                        if (localSelectedField != null) ...[
                          _buildLabel(
                            '${AppLocalizations.of(context)!.value} *',
                          ),
                          if (localSelectedField?.id == "DocumentType") ...[
                            SearchableMultiColumnDropdownField<FilterItem>(
                              labelText: '',
                              items: externalFields,
                              selectedValue: selectedFieldExternal,
                              columnHeaders: const ["Select Value"],
                              searchValue: (item) => item.label,
                              displayText: (item) => item?.label ?? '',
                              onChanged: (value) {
                                setStateModal(() {
                                  selectedFieldExternal = value;
                                  controller.localFieldValue = '';
                                });
                              },
                              rowBuilder: (item, query) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(item.label)),
                                    ],
                                  ),
                                );
                              },

                              // modalBarrierColor: Colors.black.withOpacity(0.3),
                              // modalBottomSheetOptions: const ModalBottomSheetOptions(
                              //   backgroundColor: Colors.transparent,
                              //   clipBehavior: Clip.none,
                              // ),
                              // dropdownHeight: 300,
                              // dropdownBorderRadius: 12,
                              // dropdownElevation: 4,
                              dropdownMaxHeight: 300,
                            ),
                          ] else ...[
                            _buildValueInput(
                              field: localSelectedField!,
                              value: controller.localFieldValue ?? '',
                              onChanged: (value) {
                                setStateModal(() {
                                  controller.localFieldValue = value;
                                  selectedFieldExternal = FilterItem(
                                    id: value,
                                    label: value,
                                  );
                                });
                              },
                            ),
                          ],
                        ],

                        // Action Buttons
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => {
                                setState(() {
                                  localSelectedField = null;
                                  selectedFieldExternal = null;
                                  selectedType = '';
                                  selectedField = null;
                                }),
                                futureData = controller.fetchApprovalData(
                                  [],
                                  '',
                                ),
                                Navigator.pop(context),
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.cancel,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  setState(() {
                                    selectedType = localSelectedType;
                                    selectedField = localSelectedField;
                                    fieldValue = controller.localFieldValue!;
                                  });
      Navigator.pop(context);
                                  final skippedList = controller
                                      .skippedWorkItems
                                      .toList();
                                      print("External$selectedType");
                                  if (selectedType == "External") {
                                    await controller
                                        .fetchApprovalDetailsExternal(
                                          controller.workitemrecid!, // if RxInt
                                          localSelectedField!.id,
                                          selectedFieldExternal?.label ?? "",
                                        );
                                  } else {
                                    // ✅ Await first API
                                    futureData =  controller.fetchApprovalData(
                                      skippedList,
                                      field: localSelectedField!.id,
                                      value: controller.localFieldValue!,
                                      selectedFieldExternal?.label ?? "",
                                    );
                                  }

                              
                                  // ✅ Await second API

                                  // ✅ After both APIs complete

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Filtered by ${localSelectedField!.label}",
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                } catch (e) {
                                  debugPrint("Filter Error: $e");
                                
                                }
                              },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  11,
                                  1,
                                  61,
                                ),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 3,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.applyFilters,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper: Reusable Label Widget
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          // color: Color.fromARGB(255, 40, 40, 40),
        ),
      ),
    );
  }

  // Dynamic Value Input Builder
  Widget _buildValueInput({
    required FilterItem field,
    required String value,
    required Function(String) onChanged,
  }) {
    const inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Colors.transparent),
    );

    const focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Colors.blueAccent, width: 2),
    );
    if (field.type == 'boolean') {
      return DropdownButtonFormField<String>(
        value: value.isEmpty ? null : value,
        decoration: const InputDecoration(
          // labelText: 'Value *',
          labelStyle: TextStyle(color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          ),
          filled: false,
          border: inputBorder,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: booleanOptions.map((opt) {
          return DropdownMenuItem<String>(value: opt, child: Text(opt));
        }).toList(),
        onChanged: (val) => onChanged(val ?? ''),
        dropdownColor: Colors.white,
      );
    } else if (field.type == 'number') {
      return TextField(
        keyboardType: TextInputType.number,

        decoration: const InputDecoration(
          // labelText: 'Value *',
          hintText: 'Eg: 1000',
          labelStyle: TextStyle(color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          ),
          border: inputBorder,
          filled: false,
        ),
        onChanged: onChanged,
      );
    } else {
      return TextField(
        decoration: const InputDecoration(
          // labelText: 'Value *',
          hintText: 'Eg: EXP001',
          labelStyle: TextStyle(color: Colors.grey),
          border: inputBorder,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          ),

          filled: false,
        ),
        onChanged: onChanged,
      );
    }
  }
}
