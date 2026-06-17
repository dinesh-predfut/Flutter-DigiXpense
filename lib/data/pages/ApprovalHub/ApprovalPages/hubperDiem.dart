// Full Updated Code with Null Safety Fixes
import 'package:diginexa/core/comman/widgets/accountDistribution.dart';
import 'package:diginexa/core/comman/widgets/button.dart';
import 'package:diginexa/core/comman/widgets/pageLoaders.dart';
import 'package:diginexa/core/comman/widgets/searchDropown.dart';
import 'package:diginexa/core/constant/Parames/colors.dart';
import 'package:diginexa/core/utils.dart';
import 'package:diginexa/data/models.dart';
import 'package:diginexa/data/pages/screen/widget/router/router.dart';
import 'package:diginexa/data/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../core/comman/widgets/multiselectDropdown.dart';
import '../../../../../core/comman/widgets/permissionHelper.dart';
import '../../../../../l10n/app_localizations.dart';

class HubCreatePerDiemPage extends StatefulWidget {
  final bool isReadOnly;
  final PerdiemResponseModel? item;
  const HubCreatePerDiemPage({super.key, this.item, required this.isReadOnly});

  @override
  State<HubCreatePerDiemPage> createState() => _HubCreatePerDiemPageState();
}

class _HubCreatePerDiemPageState extends State<HubCreatePerDiemPage>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<Controller>();
  final Map<String, TextEditingController> fieldControllers = {};
  bool _showProjectError = false;
  bool _showLocationError = false;
  String? statusApproval;
  late int? workitemrecid;
  bool allowMultSelect = false;
  bool allowCashAd = false;
  String? expenseIdError;
  String? noOfDaysError;
  String? perDiemError;
  String? employeeError;

  late Future<List<ExpenseHistory>> historyFuture;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      historyFuture = controller.fetchExpenseHistory(widget.item!.recId);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initializeDataCashAdvance();
      _loadSettings();
      controller.fetchEmployeesID();
      await controller.loadSequenceModules();
      controller.loadAllCustomFieldValues(
        savedValues: widget.item?.expenseHeaderCustomFieldValues,
      );
          
      
      controller.fetchLocation();
      controller.fetchUsers();
      loadAndAppendCashAdvanceList();
      controller.fetchCustomFields();
      controller.configuration();
      controller.isReadOnly = widget.isReadOnly;
      _initializeData();
      if (widget.item != null) {
        controller.cashAdvReqIds = widget.item!.cashAdvReqId ?? '';
        statusApproval = widget.item!.approvalStatus ?? 'Unknown';

        if (widget.item!.stepType == "Approval") {
          controller.isEditModePerdiem = false;
          controller.isEditMode = false;
          controller.isReadOnly = true;
        }
        else{
          controller.isEditModePerdiem = true;
          controller.isEditMode = true;
          controller.isReadOnly = true;
        }
        // if (widget.item!.approvalStatus == "Approved" ||
        //     widget.item!.approvalStatus == "Pending") {
        //   setState(() {
        //     controller.isEditModePerdiem = false;
        //   });
        //   // controller.isEditMode = false;
        //   // controller.isReadOnly = true;
        // }
        workitemrecid = widget.item!.workitemrecid;

        controller.split = (widget.item!.accountingDistributions).map((dist) {
          return AccountingSplit(
            paidFor: dist.dimensionValueId ?? '',
            percentage: dist.allocationFactor ?? 0.0,
            amount: dist.transAmount ?? 0.0,
          );
        }).toList();

        setState(() {}); // safe here
      } else {
        statusApproval = 'Unknown';
        workitemrecid = null;
      }
    });
    _initializeData();
    // ✅ Defer all UI-affecting state updates
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.item == null) {
        setState(() {
          controller.isEditModePerdiem = true;
        });
      } else {
        setState(() {
          controller.isEditModePerdiem = false;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.item == null) {
        await controller.fetchPerDiemRates();
        controller.fetchExchangeRatePerdiem();
        print("isReadOnly ${widget.isReadOnly}");
      }
    });
  }

  Future<void> _loadSettings() async {
    final settings = await controller.fetchGeneralSettings();
    if (settings != null) {
      setState(() {
        allowMultSelect = settings.allowMultipleCashAdvancesPerExpenseReg;
        allowCashAd = settings.allowCashAdvAgainstExpenseReg;
        print("allowDocAttachments$allowMultSelect");
      });
    }
  }

  Future<void> loadAndAppendCashAdvanceList() async {
    controller.cashAdvanceListDropDown.clear();
    print("cashAdvanceListDropDown${controller.cashAdvanceListDropDown}");
    try {
      final newItems = await controller.fetchExpenseCashAdvanceList();
      controller.cashAdvanceListDropDown.addAll(newItems); // ✅ Append here
      print("cashAdvanceListDropDown${controller.cashAdvanceListDropDown}");
    } catch (e) {
      Get.snackbar('Error', e.toString());
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

  bool validateForm() {
    bool isValid = true;

    setState(() {
      // Validate Project Id
      final projectMandatory = isFieldMandatory('Project Id');
      if (controller.selectedProject == null && projectMandatory) {
        _showProjectError = true;
        isValid = false;
      } else {
        _showProjectError = false;
      }
      if (controller.employeeDropDownController.text.trim().isEmpty) {
        setState(() {
          employeeError = AppLocalizations.of(context)!.fieldRequired;
        });
        isValid = false;
      }
      // Validate Location
      final locationMandatory = isFieldMandatory('Location');
      if (controller.selectedLocation == null && locationMandatory) {
        _showLocationError = true;
        isValid = false;
      } else {
        _showLocationError = false;
      }

      // Validate Custom Fields
      for (var field in controller.customFields.where(
        (field) => field['ExpenseType'] == 'PerDiem',
      )) {
        final bool isCustomMandatory =
            field['IsMandatory'].toString().toLowerCase() == 'true';

        final String fieldType = field['FieldType'].toString().toLowerCase();

        dynamic value;

        /// Handle dropdown/list fields
        if (fieldType == 'list' || fieldType == 'customlist') {
          value = field['SelectedValue'];
        } else {
          value = field['EnteredValue'];
        }

        print("------------ CUSTOM FIELD ------------");
        print("Field Name     : ${field['FieldName']}");
        print("Expense Type   : ${field['ExpenseType']}");
        print("Field Type     : $fieldType");
        print("Mandatory      : $isCustomMandatory");
        print("Entered Value  : ${field['EnteredValue']}");
        print("Selected Value : ${field['SelectedValue']}");
        print("Final Value    : $value");

        final bool isEmptyValue =
            value == null ||
            value.toString().trim().isEmpty ||
            value.toString().toLowerCase() == 'null';

        if (isCustomMandatory && isEmptyValue) {
          field['Error'] = AppLocalizations.of(context)!.fieldRequired;
          isValid = false;

          print("❌ Validation Failed");
        } else {
          field['Error'] = null;

          print("✅ Validation Passed");
        }
      }
    });
    final hideField = controller.hasModule("Expense");

    if (!hideField) {
      if (controller.expenseIdController.text.trim().isEmpty) {
        setState(() {
          expenseIdError = AppLocalizations.of(
            context,
          )!.fieldRequired; // 🔥 create this variable
        });
        isValid = false;
      } else {
        setState(() {
          expenseIdError = null;
        });
      }
    }
    // Validate No Of Days
    if (controller.daysController.text.trim().isEmpty) {
      noOfDaysError = AppLocalizations.of(context)!.fieldRequired;
      isValid = false;
    } else if (double.tryParse(controller.daysController.text.trim()) == null) {
      noOfDaysError = AppLocalizations.of(context)!.fieldRequired;
      isValid = false;
    } else {
      noOfDaysError = null;
    }

    // Validate Per Diem
    if (controller.perDiemController.text.trim().isEmpty) {
      perDiemError = AppLocalizations.of(context)!.fieldRequired;
      isValid = false;
    } else {
      perDiemError = null;
    }
    return isValid;
  }

  Future<void> _initializeData() async {
    final todayOrg = todayInOrgTimezone();
    final fromMs = toStartOfDayUtc(todayOrg);
    final toMs = toEndOfDayUtc(todayOrg);

    final fromDateUtc = DateTime.fromMillisecondsSinceEpoch(
      fromMs,
      isUtc: true,
    );
    final toDateUtc = DateTime.fromMillisecondsSinceEpoch(toMs, isUtc: true);

    // This will now correctly convert UTC to org-local for display
    controller.fromDateController.text = formatDate(fromDateUtc);
    controller.toDateController.text = formatDate(toDateUtc);

    print("FROM MS (UTC): $fromMs");
    print("TO MS (UTC): $toMs");
    print("FROM DATE UTC: $fromDateUtc");
    print("TO DATE UTC: $toDateUtc");
    print("FROM DATE DISPLAY: ${controller.fromDateController.text}");
    print("TO DATE DISPLAY: ${controller.toDateController.text}");

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([controller.fetchProjectName()]);
    });

    // Rest of your existing code for editing items...
    if (widget.item != null) {
      controller.isLoadingGE2.value = true;
      print("Its Called ");
      final item = widget.item!;
      controller.isManualEntry = true;

      // Safe project matching with fallback
      final matchedProject = controller.project.firstWhere(
        (p) => p.code == item.projectId,
        orElse: () => Project(name: '', code: '', isNotEmpty: false),
      );

      if (matchedProject.isNotEmpty) {
        controller.selectedProject = matchedProject;
        print("controller.selectedProject${controller.selectedProject!.code} ");
        controller.projectIdController.text = matchedProject.code;
      } else {
        controller.selectedProject = null;
        controller.projectIdController.clear();
      }

      // Safe location handling
      if (item.location != null && item.location!.trim().isNotEmpty) {
        final matchedLocation = controller.location.firstWhere(
          (l) => l.location == item.location,
          orElse: () => LocationModel(
            location: '',
            country: '',
            description: '',
            createdBy: '',
            modifiedBy: '',
            organizationId: 0,
            recId: 0,
            region: '',
            city: '',
            createdDatetime: 0,
            modifiedDatetime: 0,
            subOrganizationId: 0,
            state: '',
          ),
        );

        if (matchedLocation.location.isNotEmpty) {
          controller.selectedLocation = matchedLocation;
          controller.locationController.text = matchedLocation.location;
        } else {
          controller.selectedLocation = null;
          controller.locationController.clear();
        }
      } else {
        controller.selectedLocation = null;
        controller.locationController.clear();
      }

      if (controller.cashAdvanceIds.text.isNotEmpty) {
        final ids = controller.cashAdvanceIds.text
            .split(',')
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList();

        controller.cashAdvanceIds.text = ids.join(',');

        controller.multiSelectedItems.clear();
        controller.multiSelectedItems.addAll(
          controller.cashAdvanceListDropDown.where(
            (e) => ids.contains(e.cashAdvanceReqId),
          ),
        );
      }

      // Safe date handling for existing items - FIXED: Use formatDate for display
      if (item.fromDate != null) {
        final fromDateUtc = DateTime.fromMillisecondsSinceEpoch(
          item.fromDate,
          isUtc: true,
        );
        controller.fromDateController.text = formatDate(fromDateUtc);
      }

      if (item.toDate != null) {
        final toDateUtc = DateTime.fromMillisecondsSinceEpoch(
          item.toDate,
          isUtc: true,
        );
        controller.toDateController.text = formatDate(toDateUtc);
      }

      controller.expenseIdController.text = item.expenseId ?? '';
      controller.employeeDropDownController.text = item.employeeId ?? '';
      controller.employeeName.text = item.employeeName ?? '';
      controller.daysController.text = (item.noOfDays ?? 0).toString();

      await controller.fetchPerDiemRates();
      controller.amountInController.clear();
      controller.allocationLines.clear();
      controller.amountInController.text = (item.totalAmountReporting ?? 0.0)
          .toString();
      controller.exchangeamountInController.text =
          (item.totalAmountTrans ?? 0.0).toString();
      controller.purposeController.text = item.description ?? '';

      historyFuture = controller.fetchExpenseHistory(item.recId);

      controller.allocationLines.clear();
      controller.allocationLines = item.allocationLines ?? [];
      for (var item in controller.allocationLines) {
        controller.perDiemController.text = item.perDiemId ?? '';
      }

      print(
        "allocationLinesData ${controller.allocationLines.map((e) => e.toJson()).toList()}",
      );
      controller.accountingDistributions = item.accountingDistributions ?? [];
      controller.isLoadingGE2.value = false;
    }
  }

  String formatDate(DateTime date) {
    // Ensure we're working with UTC
    final DateTime utcDate = date.isUtc ? date : date.toUtc();

    // Convert UTC to organization's local time for display
    final offsetMs = getTimezoneOffsetMs();
    final DateTime orgLocalDate = DateTime.fromMillisecondsSinceEpoch(
      utcDate.millisecondsSinceEpoch + offsetMs,
      isUtc: true,
    );

    return DateFormat(
      controller.selectedFormat?.key ?? 'dd/MM/yyyy',
    ).format(orgLocalDate);
  }

  Future<void> _initializeDataCashAdvance() async {
    await loadAndAppendCashAdvanceList();
    initializeCashAdvanceSelection();
  }

  void initializeCashAdvanceSelection() {
    String? backendSelectedIds = controller.cashAdvReqIds;
    print("preloadCashAdvanceSelections$backendSelectedIds");
    controller.preloadCashAdvanceSelections(
      controller.cashAdvanceListDropDown,
      backendSelectedIds,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    Color buttonColor;
    switch (statusApproval) {
      case 'Approved':
        buttonColor = Colors.green;
        break;
      case 'Rejected':
        buttonColor = Colors.red;
        break;
      case 'Pending':
        buttonColor = Colors.orange;
        break;
      case "Created":
        buttonColor = Colors.blue;
        break;
      default:
        buttonColor = Colors.grey;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (controller.expenseIdController.text.isEmpty && widget.item != null) {
        controller.isLoadingGE2.value = true;
      } else {
        controller.isLoadingGE2.value = false;
      }
    });
    return WillPopScope(
      onWillPop: () async {
        if (!controller.isEditModePerdiem) {
          controller.clearFormFieldsPerdiem();
          controller.isEditModePerdiem = true;
          return true;
        }

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
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  AppLocalizations.of(context)!.ok,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );

        if (shouldExit ?? false) {
          controller.clearFormFieldsPerdiem();
          controller.isEditModePerdiem = true;
          return true;
        }

        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,

        body: Obx(() {
          return controller.isLoadingGE2.value
              ? const SkeletonLoaderPage()
              : Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        if (widget.item != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  debugPrint(
                                    "Status: ${controller.isEditModePerdiem.toString()}",
                                  );
                                },
                                icon: const Icon(
                                  Icons.donut_large,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  statusApproval ??
                                      'Unknown', // ✅ Safe null handling
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: buttonColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  minimumSize: const Size(0, 32),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            loc.perDiemDetails,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (widget.item != null)
                          buildTextField(
                            "${loc.expenseId}s*",
                            controller.expenseIdController,
                            null,
                            readOnly: false,
                          ),
                        if (widget.item == null) ...[
                          Obx(() {
                            if (controller.isSequenceLoading.value) {
                              return const SizedBox(); // or loader
                            }

                            final hideField = controller.hasModule("Expense");

                            if (hideField) {
                              return const SizedBox.shrink(); // ✅ hide
                            }

                            return Column(
                              children: [
                                TextFormField(
                                  controller: controller.expenseIdController,
                                  decoration: InputDecoration(
                                    labelText: '${loc.expenseId} *',
                                    errorText: expenseIdError,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          }),
                        ],

                        if (widget.item != null)
                          buildTextField(
                            "${loc.employeeId} *",
                            controller.employeeDropDownController,
                            null,
                            readOnly: false,
                          ),
                        if (widget.item != null)
                          buildTextField(
                            "${loc.employeeName} *",
                            controller.employeeName,
                            null,
                            readOnly: false,
                          ),
                        if (widget.item == null) const SizedBox(height: 16),
                        if (widget.item == null &&
                            PermissionHelper.canRead("User Delegates") == true)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SearchableMultiColumnDropdownField<EmployeeId>(
                                labelText: '${loc.employeeId} *',
                                columnHeaders: [
                                  loc.employeeName,
                                  loc.employeeId,
                                ],
                                items: controller.employeesID,
                                controller:
                                    controller.employeeDropDownController,
                                selectedValue:
                                    controller.selectedEmployeeID.value,
                                searchValue: (emp) =>
                                    '${emp.employeeName} ${emp.employeeId}',
                                displayText: (emp) => emp.employeeId,
                                validator: (emp) =>
                                    controller
                                        .employeeDropDownController
                                        .text
                                        .isEmpty
                                    ? loc.fieldRequired
                                    : null,
                                onChanged: (emp) {
                                  if (emp == null) {
                                    controller.fetchEmployees();
                                  }
                                  setState(() {
                                    controller.selectedEmployeeID.value = emp;
                                    controller.employeeDropDownController.text =
                                        emp!.employeeId;
                                    controller.employeeName.text =
                                        emp.employeeName;
                                  });
                                },
                                rowBuilder: (emp, searchQuery) {
                                  bool isMatch = false;
                                  if (searchQuery.isNotEmpty) {
                                    final searchableText =
                                        '${emp.employeeName} ${emp.employeeId}'
                                            .toLowerCase();
                                    isMatch = searchableText.contains(
                                      searchQuery.toLowerCase(),
                                    );
                                  }

                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 0,
                                      horizontal: 0,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(
                                              emp.employeeName,
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(
                                              emp.employeeId,
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),

                              if (employeeError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    employeeError!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        if (employeeError != null && widget.item == null)
                          // const SizedBox(height: 8),
                        ...controller.configList
                            .where(
                              (field) =>
                                  field['FieldName'] == 'Project Id' &&
                                  field['IsEnabled'] == true,
                            )
                            .map((field) {
                              final String label = field['FieldName'];
                              final bool isMandatory =
                                  field['IsMandatory'] ?? false;

                              Widget inputField;

                              inputField = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SearchableMultiColumnDropdownField<Project>(
                                    labelText:
                                        '${loc.projectId} ${isMandatory ? "*" : ""}',
                                    columnHeaders: [
                                      loc.projectName,
                                      loc.projectId,
                                    ],
                                    enabled: controller.isEditModePerdiem,
                                    controller: controller.projectIdController,
                                    items: controller.project,
                                    selectedValue: controller.selectedProject,
                                    searchValue: (proj) =>
                                        '${proj.name} ${proj.code}',
                                    displayText: (proj) => proj.code,
                                    onChanged: (proj) {
                                      loadAndAppendCashAdvanceList();
                                      setState(() {
                                        controller.selectedProject = proj;
                                        if (proj != null) {
                                          _showProjectError = false;
                                        }
                                      });
                                    },
                                    rowBuilder: (proj, searchQuery) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 16,
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 10),
                                            Expanded(child: Text(proj.name)),
                                            Expanded(child: Text(proj.code)),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  if (_showProjectError)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
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
                        ...controller.configList
                            .where(
                              (field) =>
                                  field['FieldName'] == 'Location' &&
                                  field['IsEnabled'] == true,
                            )
                            .map((field) {
                              final bool isMandatory =
                                  field['IsMandatory'] ?? false;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SearchableMultiColumnDropdownField<
                                    LocationModel
                                  >(
                                    labelText:
                                        '${loc.location} ${isMandatory ? "*" : ""}',
                                    items: controller.location,
                                    selectedValue: controller.selectedLocation,
                                    enabled: controller.isEditModePerdiem,
                                    controller: controller.locationController,
                                    searchValue: (proj) => proj.location,
                                    displayText: (proj) => proj.location,
                                    validator: (proj) =>
                                        isMandatory && proj == null
                                        ? loc.selectLocale
                                        : null,
                                    onChanged: (proj) async {
                                      controller.selectedLocation = proj;
                                      if (proj != null) {
                                        controller.selectedLocationController =
                                            proj.location;
                                        await controller.fetchPerDiemRates();
                                        controller.fetchExchangeRatePerdiem();
                                      }
                                      field['Error'] = null;
                                    },
                                    columnHeaders: [loc.location, loc.country],
                                    rowBuilder: (proj, searchQuery) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 16,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(proj.location),
                                            ),
                                            Expanded(child: Text(proj.country)),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  if (_showLocationError)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        loc.pleaseSelectLocation,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 14),
                                ],
                              );
                            })
                            .toList(),

                        // if (allowCashAd) const SizedBox(height: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (allowCashAd)
                              MultiSelectMultiColumnDropdownField<
                                CashAdvanceDropDownModel
                              >(
                                labelText: loc.cashAdvanceRequest,
                                items: controller.cashAdvanceListDropDown,
                                isMultiSelect: allowMultSelect,
                                selectedValue: controller.singleSelectedItem,
                                selectedValues: controller.multiSelectedItems,
                                enabled: controller.isEditModePerdiem,
                                searchValue: (proj) => proj.cashAdvanceReqId,
                                displayText: (proj) => proj.cashAdvanceReqId,
                                validator: (proj) => proj == null
                                    ? loc.pleaseSelectCashAdvanceField
                                    : null,
                                onChanged: (item) {},
                                onMultiChanged: (items) {
                                  controller.multiSelectedItems.clear();
                                  controller.multiSelectedItems.addAll(items);

                                  controller.cashAdvanceIds.text = items
                                      .map((e) => e.cashAdvanceReqId)
                                      .join(',');
                                },
                                columnHeaders: [loc.requestId, loc.requestDate],
                                controller: controller.cashAdvanceIds,
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
                            const SizedBox(height: 14),
                            buildDateField(
                              "${loc.fromDate} *",
                              controller.fromDateController,
                              true,
                              enabled: controller.isEditModePerdiem,
                            ),
                            buildDateField(
                              "${loc.toDate} *",
                              controller.toDateController,
                              false,
                              enabled: controller.isEditModePerdiem,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: buildTextField(
                                    "${loc.noOfDays}*",
                                    controller.daysController,
                                    noOfDaysError,
                                    readOnly: false,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (widget.item == null ||
                                    controller.isEditModePerdiem)
                                  SizedBox(
                                    width: 50,
                                    child: stylishSettingsButton(
                                      onPressed: () {
                                        _showSettingsPopup();
                                      },
                                    ),
                                  ),
                              ],
                            ),
                            buildTextField(
                              "${loc.perDiem}*",
                              controller.perDiemController,
                              perDiemError,
                              readOnly: false,
                            ),
                            buildTextField(
                              '${loc.totalAmountIN} ${controller.perDiemexchangeCurrencyCode.value}',
                              controller.exchangeamountInController,
                              null,
                              readOnly: false,
                            ),
                            buildTextField(
                              '${loc.totalAmountIN} ${controller.organizationCurrency}',
                              controller.amountInController,
                              null,
                              readOnly: false,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: TextField(
                                controller: controller.purposeController,
                                enabled: controller.isEditModePerdiem,
                                decoration: InputDecoration(
                                  labelText: loc.purpose,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),

                            Obx(() {
                              return Column(
                                children: controller.customFields
                                    .where(
                                      (field) =>
                                          field['ExpenseType'] == 'PerDiem',
                                    ) // Add this filter
                                    .map((field) {
                                      final String label =
                                          field['FieldLabel'] ??
                                          field['FieldName'];
                                      final bool isMandatory =
                                          field['IsMandatory'] ?? false;
                                      final String fieldKey =
                                          field['FieldName'];

                                      // ✅ Create controller once, sync value from customFields
                                      if (!fieldControllers.containsKey(
                                        fieldKey,
                                      )) {
                                        fieldControllers[fieldKey] =
                                            TextEditingController(
                                              text:
                                                  field['EnteredValue']
                                                      ?.toString() ??
                                                  '',
                                            );
                                      } else {
                                        // ✅ Sync latest value into existing controller
                                        final newText =
                                            field['EnteredValue']?.toString() ??
                                            '';
                                        if (fieldControllers[fieldKey]!.text !=
                                            newText) {
                                          fieldControllers[fieldKey]!.text =
                                              newText;
                                        }
                                      }

                                      Widget inputField;

                                      if (field['FieldType'] == 'List' ||
                                          field['FieldType'] == 'CustomList' ||
                                          field['FieldType'] == 'SystemList') {
                                        inputField =
                                            SearchableMultiColumnDropdownField<
                                              CustomDropdownValue
                                            >(
                                              labelText:
                                                  '$label${isMandatory ? " *" : ""}',
                                              items:
                                                  (field['Options']
                                                      as List<
                                                        CustomDropdownValue
                                                      >?) ??
                                                  [],
                                              selectedValue:
                                                  field['SelectedValue'],
                                              searchValue: (val) =>
                                                  val.valueName,
                                              enabled:
                                                  controller.isEditModePerdiem,
                                              displayText: (val) =>
                                                  val.valueName,
                                              columnHeaders: const [
                                                'Value ID',
                                                'Value Name',
                                              ],
                                              rowBuilder: (val, searchQuery) =>
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 10,
                                                          horizontal: 16,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            val.valueId,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            val.valueName,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              onChanged: (val) {
                                                field['SelectedValue'] = val;
                                                field['Error'] = null;
                                                controller.customFields
                                                    .refresh();
                                              },
                                            );
                                      } else if (field['FieldType'] ==
                                          'Checkbox') {
                                        inputField = CheckboxListTile(
                                          title: Text(
                                            '$label${isMandatory ? " *" : ""}',
                                          ),
                                          value:
                                              field['EnteredValue'] ??
                                              false, // ✅ reads live from map
                                          enabled: controller.isEditModePerdiem,
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          contentPadding: EdgeInsets.zero,
                                          onChanged:
                                              controller.isEditModePerdiem
                                              ? (bool? val) {
                                                  field['EnteredValue'] =
                                                      val ?? false;
                                                  controller.customFields
                                                      .refresh();
                                                }
                                              : null,
                                        );
                                      } else if (field['FieldType'] == 'Date' ||
                                          field['FieldType'] == 'Date&Time') {
                                        final bool isDateTime =
                                            field['FieldType'] == 'Date&Time';

                                        // ✅ Sync date text into controller
                                        fieldControllers[fieldKey]!.text =
                                            field['EnteredValue'] != null
                                            ? isDateTime
                                                  ? DateFormat(
                                                      'dd/MM/yyyy hh:mm a',
                                                    ).format(
                                                      field['EnteredValue'],
                                                    )
                                                  : DateFormat(
                                                      'dd/MM/yyyy',
                                                    ).format(
                                                      field['EnteredValue'],
                                                    )
                                            : '';

                                        inputField = TextFormField(
                                          enabled: controller.isEditModePerdiem,
                                          readOnly: true,
                                          controller:
                                              fieldControllers[fieldKey], // ✅ use controller
                                          decoration: InputDecoration(
                                            labelText:
                                                '$label${isMandatory ? " *" : ""}',
                                            border: const OutlineInputBorder(),
                                            errorText: field['Error'],
                                            suffixIcon: const Icon(
                                              Icons.calendar_today,
                                            ),
                                          ),
                                          onTap: controller.isEditModePerdiem
                                              ? () async {
                                                  final DateTime?
                                                  pickedDate = await showDatePicker(
                                                    context: context,
                                                    initialDate:
                                                        field['EnteredValue'] ??
                                                        DateTime.now(),
                                                    firstDate: DateTime(2000),
                                                    lastDate: DateTime(2100),
                                                  );
                                                  if (pickedDate == null)
                                                    return;

                                                  if (isDateTime) {
                                                    final TimeOfDay?
                                                    pickedTime = await showTimePicker(
                                                      context: context,
                                                      initialTime:
                                                          field['EnteredValue'] !=
                                                              null
                                                          ? TimeOfDay.fromDateTime(
                                                              field['EnteredValue'],
                                                            )
                                                          : TimeOfDay.now(),
                                                    );
                                                    if (pickedTime == null)
                                                      return;
                                                    field['EnteredValue'] =
                                                        DateTime(
                                                          pickedDate.year,
                                                          pickedDate.month,
                                                          pickedDate.day,
                                                          pickedTime.hour,
                                                          pickedTime.minute,
                                                        );
                                                  } else {
                                                    field['EnteredValue'] =
                                                        pickedDate;
                                                  }
                                                  controller.customFields
                                                      .refresh();
                                                }
                                              : null,
                                          validator: (value) {
                                            if (isMandatory &&
                                                field['EnteredValue'] == null) {
                                              return '$label is required';
                                            }
                                            return null;
                                          },
                                        );
                                      } else if (field['FieldType'] ==
                                          'LongInteger') {
                                        inputField = TextFormField(
                                          enabled: controller.isEditModePerdiem,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          controller:
                                              fieldControllers[fieldKey], // ✅ use controller
                                          decoration: InputDecoration(
                                            labelText:
                                                '$label${isMandatory ? " *" : ""}',
                                            border: const OutlineInputBorder(),
                                            errorText: field['Error'],
                                          ),
                                          onChanged: (value) {
                                            field['EnteredValue'] =
                                                int.tryParse(value);
                                          },
                                          validator: (value) {
                                            if (isMandatory &&
                                                (value == null ||
                                                    value.trim().isEmpty)) {
                                              return '$label is required';
                                            }
                                            return null;
                                          },
                                        );
                                      } else if (field['FieldType'] ==
                                          'Decimal') {
                                        inputField = TextFormField(
                                          enabled: controller.isEditModePerdiem,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d+\.?\d*'),
                                            ),
                                          ],
                                          controller:
                                              fieldControllers[fieldKey], // ✅ use controller
                                          decoration: InputDecoration(
                                            labelText:
                                                '$label${isMandatory ? " *" : ""}',
                                            border: const OutlineInputBorder(),
                                            errorText: field['Error'],
                                          ),
                                          onChanged: (value) {
                                            field['EnteredValue'] =
                                                double.tryParse(value);
                                          },
                                          validator: (value) {
                                            if (isMandatory &&
                                                (value == null ||
                                                    value.trim().isEmpty)) {
                                              return '$label is required';
                                            }
                                            return null;
                                          },
                                        );
                                      } else if (field['FieldType'] ==
                                          'Email') {
                                        inputField = TextFormField(
                                          enabled: controller.isEditModePerdiem,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          controller:
                                              fieldControllers[fieldKey], // ✅ use controller
                                          decoration: InputDecoration(
                                            labelText:
                                                '$label${isMandatory ? " *" : ""}',
                                            border: const OutlineInputBorder(),
                                            errorText: field['Error'],
                                            suffixIcon: const Icon(
                                              Icons.email_outlined,
                                            ),
                                          ),
                                          onChanged: (value) {
                                            field['EnteredValue'] = value;
                                          },
                                          validator: (value) {
                                            if (isMandatory &&
                                                (value == null ||
                                                    value.trim().isEmpty)) {
                                              return '$label is required';
                                            }
                                            if (value != null &&
                                                value.isNotEmpty) {
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
                                      } else if (field['FieldType'] ==
                                          'MobileNumber') {
                                        inputField = TextFormField(
                                          enabled: controller.isEditModePerdiem,
                                          keyboardType: TextInputType.phone,
                                          controller:
                                              fieldControllers[fieldKey], // ✅ use controller
                                          decoration: InputDecoration(
                                            labelText:
                                                '$label${isMandatory ? " *" : ""}',
                                            border: const OutlineInputBorder(),
                                            errorText: field['Error'],
                                            suffixIcon: const Icon(
                                              Icons.phone_outlined,
                                            ),
                                          ),
                                          onChanged: (value) {
                                            field['EnteredValue'] = value;
                                          },
                                          validator: (value) {
                                            if (isMandatory &&
                                                (value == null ||
                                                    value.trim().isEmpty)) {
                                              return '$label is required';
                                            }
                                            if (value != null &&
                                                value.isNotEmpty) {
                                              final phoneRegex = RegExp(
                                                r'^\+?[\d\s\-]{7,15}$',
                                              );
                                              if (!phoneRegex.hasMatch(value)) {
                                                return 'Enter a valid mobile number';
                                              }
                                            }
                                            return null;
                                          },
                                        );
                                      } else {
                                        // ✅ Default Text
                                        inputField = TextFormField(
                                          enabled: controller.isEditModePerdiem,
                                          keyboardType: TextInputType.text,
                                          controller:
                                              fieldControllers[fieldKey],
                                          decoration: InputDecoration(
                                            labelText:
                                                '$label${isMandatory ? " *" : ""}',
                                            border: const OutlineInputBorder(),
                                            errorText: field['Error'],
                                          ),
                                          onChanged: (value) {
                                            field['EnteredValue'] = value;
                                          },
                                          validator: (value) {
                                            if (isMandatory &&
                                                (value == null ||
                                                    value.trim().isEmpty)) {
                                              return '$label is required';
                                            }
                                            return null;
                                          },
                                        );
                                      }

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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    final double lineAmount =
                                        double.tryParse(
                                          controller.amountInController.text,
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
                                            paidFor: e?.dimensionValueId ?? '',
                                            percentage:
                                                e?.allocationFactor ?? 0.0,
                                            amount: e?.transAmount ?? 0.0,
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
                                            isEnable:
                                                controller.isEditModePerdiem,
                                            splits: controller.split,
                                            lineAmount: lineAmount,
                                            onChanged: (i, updatedSplit) {
                                              if (!mounted) return;
                                              controller.split[i] =
                                                  updatedSplit;
                                            },
                                            onDistributionChanged: (newList) {
                                              if (!mounted) return;
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
                            if (widget.item != null) const SizedBox(height: 10),
                            if (widget.item != null)
                              _buildSection(
                                title: loc.trackingHistory,
                                children: [
                                  const SizedBox(height: 12),
                                  FutureBuilder<List<ExpenseHistory>>(
                                    future: historyFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      if (snapshot.hasError) {
                                        return Center(
                                          child: Text(
                                            "No Data Available Please Skip Next",
                                          ),
                                        );
                                      }

                                      final historyList = snapshot.data!;
                                      if (historyList.isEmpty) {
                                        return Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Text(
                                              loc.noHistoryMessage,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      print("historyList: $historyList");
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
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
                            const SizedBox(height: 20),

                            if (widget.item != null &&
                                widget.item!.stepType == "Review") ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: Obx(() {
                                      bool isLoadingUpdate =
                                          controller.buttonLoaders['update'] ??
                                          false;
                                      bool isAnyLoading = controller
                                          .buttonLoaders
                                          .values
                                          .any((loading) => loading == true);

                                      return ElevatedButton(
                                        onPressed:
                                            (isLoadingUpdate || isAnyLoading)
                                            ? null
                                            : () async {
                                                controller.setButtonLoading(
                                                  'update',
                                                  true,
                                                );
                                                try {
                                                  if (validateForm()) {
                                                    await controller
                                                        .hubperdiemApprovalReview(
                                                          context,
                                                          false,
                                                          widget
                                                              .item!
                                                              .workitemrecid,
                                                          widget.item!.recId
                                                              .toString(),
                                                          widget.item!.expenseId
                                                              .toString(),
                                                        );
                                                  } else {
                                                    print("Validation failed");
                                                  }
                                                } finally {
                                                  controller.setButtonLoading(
                                                    'update',
                                                    false,
                                                  );
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            3,
                                            20,
                                            117,
                                          ),
                                        ),
                                        child: isLoadingUpdate
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.update,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Obx(() {
                                      bool isLoadingAccept =
                                          controller
                                              .buttonLoaders['updateAccept'] ??
                                          false;
                                      bool isAnyLoading = controller
                                          .buttonLoaders
                                          .values
                                          .any((loading) => loading == true);

                                      return ElevatedButton(
                                        onPressed:
                                            (isLoadingAccept || isAnyLoading)
                                            ? null
                                            : () async {
                                                controller.setButtonLoading(
                                                  'updateAccept',
                                                  true,
                                                );
                                                try {
                                                  await controller
                                                      .hubperdiemApprovalReview(
                                                        context,
                                                        true,
                                                        widget
                                                            .item!
                                                            .workitemrecid,
                                                        widget.item!.recId
                                                            .toString(),
                                                        widget.item!.expenseId
                                                            .toString(),
                                                      );
                                                } finally {
                                                  controller.setButtonLoading(
                                                    'updateAccept',
                                                    false,
                                                  );
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            3,
                                            20,
                                            117,
                                          ),
                                        ),
                                        child: isLoadingAccept
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.updateAndAccept,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                      );
                                    }),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: Obx(() {
                                      bool isLoading =
                                          controller.buttonLoaders['reject'] ??
                                          false;
                                      return ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : () async {
                                                controller.setButtonLoading(
                                                  'reject',
                                                  true,
                                                );
                                                try {
                                                  showActionPopup(
                                                    context,
                                                    "Reject",
                                                  );
                                                } finally {
                                                  controller.setButtonLoading(
                                                    'reject',
                                                    false,
                                                  );
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            238,
                                            20,
                                            20,
                                          ),
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.reject,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        controller.skipCurrentItem(
                                          widget.item!.workitemrecid!,
                                          context,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.skip,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 20),
                            if (widget.item != null &&
                                widget.item!.stepType == "Approval") ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: Obx(() {
                                      bool isLoading =
                                          controller.buttonLoaders['approve'] ??
                                          false;
                                      return ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : () {
                                                controller.setButtonLoading(
                                                  'approve',
                                                  true,
                                                );
                                                try {
                                                  showActionPopup(
                                                    context,
                                                    "Approve",
                                                  );
                                                } finally {
                                                  controller.setButtonLoading(
                                                    'approve',
                                                    false,
                                                  );
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            30,
                                            117,
                                            3,
                                          ),
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.approve,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Obx(() {
                                      bool isLoading =
                                          controller.buttonLoaders['reject'] ??
                                          false;
                                      return ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : () {
                                                controller.setButtonLoading(
                                                  'reject',
                                                  true,
                                                );
                                                try {
                                                  showActionPopup(
                                                    context,
                                                    "Reject",
                                                  );
                                                } finally {
                                                  controller.setButtonLoading(
                                                    'reject',
                                                    false,
                                                  );
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            238,
                                            20,
                                            20,
                                          ),
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.reject,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                      );
                                    }),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Obx(() {
                                      bool isLoading =
                                          controller
                                              .buttonLoaders['escalate'] ??
                                          false;
                                      return ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : () {
                                                controller.setButtonLoading(
                                                  'escalate',
                                                  true,
                                                );
                                                try {
                                                  showActionPopup(
                                                    context,
                                                    "Escalate",
                                                  );
                                                } finally {
                                                  controller.setButtonLoading(
                                                    'escalate',
                                                    false,
                                                  );
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            3,
                                            20,
                                            117,
                                          ),
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.escalate,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Obx(() {
                                      final isLoadingClose =
                                          controller
                                              .buttonLoaders['close_review'] ??
                                          false;
                                      final isAnyLoading = controller
                                          .buttonLoaders
                                          .values
                                          .any((loading) => loading == true);

                                      return ElevatedButton(
                                        onPressed:
                                            (isLoadingClose || isAnyLoading)
                                            ? null
                                            : () async {
                                                controller.setButtonLoading(
                                                  'close_review',
                                                  true,
                                                );
                                                try {
                                                  controller.skipCurrentItem(
                                                    widget.item!.workitemrecid!,
                                                    context,
                                                  );
                                                } finally {
                                                  controller.setButtonLoading(
                                                    'close_review',
                                                    false,
                                                  );
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey,
                                        ),
                                        child: isLoadingClose
                                            ? const CircularProgressIndicator(
                                                color: Colors.black,
                                                strokeWidth: 2,
                                              )
                                            : Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.skip,
                                              ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ],
                          ],
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

  Widget buildTextField(
    String label,
    TextEditingController controller,
    String? error, {
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        enabled: readOnly,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          errorText: error,
        ),
      ),
    );
  }

  Widget buildDateField(
    String label,
    TextEditingController controllers,
    bool isFromDate, {
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: enabled
            ? () async {
                // Get current date from controller text (which is in org-local format)
                DateTime initialDate = DateTime.now();

                if (controllers.text.trim().isNotEmpty) {
                  try {
                    // Parse the displayed date (which is in org-local format)
                    initialDate = DateFormat(
                      controller.selectedFormat?.key ?? 'dd/MM/yyyy',
                    ).parseStrict(controllers.text.trim());
                  } catch (_) {}
                }

                DateTime firstDate = DateTime(2000);
                DateTime lastDate = DateTime.now();

                if (!isFromDate &&
                    controller.fromDateController.text.isNotEmpty) {
                  try {
                    final fromDateDisplay = DateFormat(
                      controller.selectedFormat?.key ?? 'dd/MM/yyyy',
                    ).parseStrict(controller.fromDateController.text.trim());

                    firstDate = fromDateDisplay;
                  } catch (_) {}
                }

                final picked = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: firstDate,
                  lastDate: lastDate,
                );

                if (picked != null) {
                  if (!isFromDate &&
                      controller.fromDateController.text.isNotEmpty) {
                    final fromDateDisplay = DateFormat(
                      controller.selectedFormat?.key ?? 'dd/MM/yyyy',
                    ).parseStrict(controller.fromDateController.text.trim());

                    if (picked.isBefore(fromDateDisplay)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "To Date cannot be earlier than From Date.",
                          ),
                        ),
                      );
                      return;
                    }
                  }

                  // Store the picked date (will be converted to UTC when saving)
                  controllers.text = DateFormat(
                    controller.selectedFormat?.key ?? 'dd/MM/yyyy',
                  ).format(picked);

                  await controller.fetchPerDiemRates();
                  controller.fetchExchangeRatePerdiem();
                  loadAndAppendCashAdvanceList();
                  if (controller.locationController.text.isNotEmpty) {
                    loadAndAppendCashAdvanceList();
                  }
                }
              }
            : null,
        child: AbsorbPointer(
          child: TextField(
            controller: controllers,
            enabled: enabled,
            decoration: InputDecoration(
              labelText: label,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
          ),
        ),
      ),
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
            children: children,
          ),
        ),
      ),
    );
  }

  void showActionPopup(BuildContext context, String status) {
    final TextEditingController commentController = TextEditingController();
    bool isCommentError = false;
    final loc = AppLocalizations.of(context)!;
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
                      loc.action,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (status == "Escalate") ...[
                      Text(
                        '${loc.selectUser}*',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => SearchableMultiColumnDropdownField<User>(
                          labelText: '${loc.user} *',
                          columnHeaders: [loc.userName, loc.userId],
                          items: controller.userList,
                          selectedValue: controller.selectedUser.value,
                          searchValue: (user) =>
                              '${user.userName} ${user.userId}',
                          displayText: (user) => user.userId,
                          onChanged: (user) {
                            controller.userIdController.text =
                                user?.userId ?? '';
                            controller.selectedUser.value = user;
                          },
                          controller: controller.userIdController,
                          rowBuilder: (user, searchQuery) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
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
                      '${AppLocalizations.of(context)!.comments} ${status == "Reject" ? "*" : ''}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: loc.enterCommentHere,
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
                        errorText: isCommentError
                            ? 'Comment is required.'
                            : null,
                      ),
                      onChanged: (value) {
                        if (isCommentError && value.trim().isNotEmpty) {
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
                            controller.closeField();
                            Navigator.pop(context);
                          },
                          child: Text(loc.close),
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
                              builder: (ctx) =>
                                  const Center(child: SkeletonLoaderPage()),
                            );

                            final success = await controller.postApprovalAction(
                              context,
                              workitemrecid: workitemrecid != null
                                  ? [workitemrecid!]
                                  : [], // ✅ Safe null handling
                              decision: status,
                              comment: commentController.text,
                            );

                            if (Navigator.of(
                              context,
                              rootNavigator: true,
                            ).canPop()) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }

                            if (!context.mounted) return;

                            if (success) {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.approvalDashboard,
                              );
                              controller.isApprovalEnable.value = false;
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to submit action'),
                                ),
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

  Widget _buildTimelineItem(ExpenseHistory item, bool isLast) {
    final loc = AppLocalizations.of(context)!;
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
                  Text(
                    item.eventType,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(item.notes),
                  const SizedBox(height: 6),
                  Text(
                    '${loc.submittedOn} ${DateFormat(controller.selectedFormat?.key ?? 'dd/MM/yyyy').format(item.createdDate)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget stylishSettingsButton({required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade400, width: 1),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: const Icon(Icons.settings, size: 18, color: Colors.black87),
      ),
    );
  }

  Future<void> _showSettingsPopup() async {
    for (var line in controller.allocationLines) {
      line.parsed = line.quantity;
      line.errorText = null;
    }
    await showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      context: context,
      builder: (_) {
        final loc = AppLocalizations.of(context)!;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      loc.allocationSettings,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (controller.allocationLines.isNotEmpty)
                      ...controller.allocationLines.map(
                        (line) => _buildAllocationCard(line, isPopup: true),
                      ),
                    if (controller.allocationLines.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          loc.noAllocationDataMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(loc.cancel),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isSaveButtonEnabled()
                              ? () {
                                  controller.setTheAllcationAmount = 0.0
                                      .toInt();

                                  if (controller.initialUnitPriceTrans ==
                                          null ||
                                      controller
                                              .initialUnitPriceTrans!
                                              .length !=
                                          controller.allocationLines.length) {
                                    controller.initialUnitPriceTrans =
                                        controller.allocationLines
                                            .map((data) => data.unitPriceTrans)
                                            .toList();
                                  }

                                  for (
                                    int i = 0;
                                    i < controller.allocationLines.length;
                                    i++
                                  ) {
                                    var data = controller.allocationLines[i];
                                    double initialUnitPrice =
                                        controller.initialUnitPriceTrans![i];

                                    print(
                                      'Before: unitPrice=$initialUnitPrice, parsed=${data.parsed}',
                                    );
                                    print(
                                      'Before: setTheAllcationAmount=${controller.setTheAllcationAmount}, parsed=${data.parsed}',
                                    );

                                    data.unitPriceTrans =
                                        initialUnitPrice * data.parsed;
                                    data.quantity = data.parsed;
                                  }

                                  controller.paidAmount.text =
                                      controller.amountInController.text;
                                  double updatedTotal = controller
                                      .allocationLines
                                      .fold(
                                        0.0,
                                        (sum, item) =>
                                            sum + item.unitPriceTrans,
                                      );

                                  if (_isSaveButtonEnabled()) {
                                    controller.amountInController.text =
                                        updatedTotal.toStringAsFixed(2);
                                    controller.exchangeamountInController.text =
                                        updatedTotal.toStringAsFixed(2);
                                  }
                                  print(
                                    "amountInController${controller.amountInController.text}",
                                  );
                                  controller.fetchExchangeRatePerdiem();

                                  if (_isSaveButtonEnabled()) {
                                    Navigator.of(context).pop();
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: "No of Days Not Valid",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        250,
                                        1,
                                        1,
                                      ),
                                      textColor: const Color.fromARGB(
                                        255,
                                        212,
                                        210,
                                        241,
                                      ),
                                      fontSize: 16.0,
                                    );
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSaveButtonEnabled()
                                ? AppColors.gradientEnd
                                : Colors.grey,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            loc.save,
                            style: TextStyle(
                              color: _isSaveButtonEnabled()
                                  ? Colors.white
                                  : Colors.black45,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  bool _isSaveButtonEnabled() {
    return controller.allocationLines.every((data) => data.errorText == null);
  }

  Widget _buildAllocationCard(AllocationLine data, {bool isPopup = false}) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildReadonlyField(
                  label: loc.effectiveFrom,
                  value: _formatDate(
                    DateTime.fromMillisecondsSinceEpoch(
                      data.effectiveFrom,
                      isUtc: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildReadonlyField(
                  label: loc.allowanceCategory,
                  value: data.expenseCategoryId,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildReadonlyField(
                  label: loc.effectiveTo,
                  value: _formatDate(
                    DateTime.fromMillisecondsSinceEpoch(
                      data.effectiveTo,
                      isUtc: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _buildEditableDaysField(data)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadonlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(value, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildEditableDaysField(AllocationLine data) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.noOfDays, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        SizedBox(
          width: 110,
          height: 40,
          child: TextFormField(
            initialValue: data.quantity.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (val) {
              setState(() {
                if (val.isEmpty) {
                  data.parsed = 0;
                  data.errorText = loc.pleaseEnterNumberOfDays;
                } else {
                  final parsed = double.tryParse(val);
                  final totalDays = double.tryParse(
                    controller.daysController.text,
                  );
                  if (parsed != null) {
                    if (parsed < 0) {
                      data.errorText = loc.numberOfDaysCannotBeNegative;
                    } else if (parsed > (totalDays ?? 0)) {
                      data.errorText =
                          "${loc.enteredDaysCannotExceedAllocated} $totalDays";
                    } else {
                      data.errorText = null;
                      data.parsed = parsed;
                    }
                  } else {
                    data.errorText = loc.pleaseEnterValidNumber;
                  }
                }
              });
            },
          ),
        ),
        if (data.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              data.errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}/${dt.year}';
  }
}
// import 'package:diginexa/core/comman/widgets/accountDistribution.dart';
// import 'package:diginexa/core/comman/widgets/button.dart';
// import 'package:diginexa/core/comman/widgets/pageLoaders.dart';
// import 'package:diginexa/core/comman/widgets/searchDropown.dart';
// import 'package:diginexa/core/constant/Parames/colors.dart';
// import 'package:diginexa/data/models.dart';
// import 'package:diginexa/data/pages/screen/widget/router/router.dart';
// import 'package:diginexa/data/service.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../../../../core/comman/widgets/multiselectDropdown.dart';
// import '../../../../l10n/app_localizations.dart';

// class HubCreatePerDiemPage extends StatefulWidget {
//   final bool isReadOnly;
//   final PerdiemResponseModel? item;
//   const HubCreatePerDiemPage({super.key, this.item, required this.isReadOnly});

//   @override
//   State<HubCreatePerDiemPage> createState() => _HubCreatePerDiemPageState();
// }

// class _HubCreatePerDiemPageState extends State<HubCreatePerDiemPage>
//     with SingleTickerProviderStateMixin {
//   final controller = Get.find<Controller>();
//   bool _showProjectError = false;
//   bool _showLocationError = false;
//   late final int workitemrecid;
//   bool allowMultSelect = false;
//   late Future<List<ExpenseHistory>> historyFuture;

//   @override
//   void initState() {
//     super.initState();
//     _loadSettings();
//     print("isReadOnly${widget.isReadOnly}");

//     if (widget.item != null) {
//       setState(() {
//         controller.isEditModePerdiem = true;
//       });

//       if (widget.item!.workitemrecid != null) {
//         workitemrecid = widget.item!.workitemrecid!;
//       }

//       historyFuture = controller.fetchExpenseHistory(widget.item!.recId);
//       controller.split = (widget.item!.accountingDistributions ?? []).map((
//         dist,
//       ) {
//         return AccountingSplit(
//           paidFor: dist.dimensionValueId ?? '',
//           percentage: dist.allocationFactor ?? 0.0,
//           amount: dist.transAmount ?? 0.0,
//         );
//       }).toList();
//     }
//   }

//   Future<void> _loadSettings() async {
//     final settings = await controller.fetchGeneralSettings();
//     if (settings != null) {
//       setState(() {
//         allowMultSelect = settings.allowMultipleCashAdvancesPerExpenseReg;
//         print("allowDocAttachments$allowMultSelect");
//       });
//     }
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       controller.isLoading.value = true;
//       controller.fetchLocation();
//       controller.fetchCustomFields();
//       controller.configuration();
//       await _initializeData();
//       controller.fetchExchangeRatePerdiem();
//     });
//   }

//   Future<void> loadAndAppendCashAdvanceList() async {
//     controller.cashAdvanceListDropDown.clear();
//     print("cashAdvanceListDropDown${controller.cashAdvanceListDropDown}");
//     try {
//       final newItems = await controller.fetchExpenseCashAdvanceList();
//       controller.cashAdvanceListDropDown.addAll(newItems);
//       print("cashAdvanceListDropDown${controller.cashAdvanceListDropDown}");
//     } catch (e) {
//       Get.snackbar('Error', e.toString());
//     }
//   }

//   bool isFieldMandatory(String fieldName) {
//     return controller.configList.any(
//       (f) =>
//           (f['FieldName']?.toString().trim().toLowerCase() ==
//               fieldName.trim().toLowerCase()) &&
//           (f['IsEnabled'].toString().toLowerCase() == 'true') &&
//           (f['IsMandatory'].toString().toLowerCase() == 'true'),
//     );
//   }

//   bool validateForm() {
//     bool isValid = true;

//     setState(() {
//       final projectMandatory = isFieldMandatory('Project Id');
//       if (controller.selectedProject == null && projectMandatory) {
//         _showProjectError = true;
//         isValid = false;
//       } else {
//         _showProjectError = false;
//       }

//       final locationMandatory = isFieldMandatory('Location');
//       if (controller.selectedLocation == null && locationMandatory) {
//         _showLocationError = true;
//         isValid = false;
//       } else {
//         _showLocationError = false;
//       }

//       for (var field in controller.customFields) {
//         final bool isCustomMandatory =
//             (field['IsMandatory'].toString().toLowerCase() == 'true');
//         final value = field['FieldType'] == 'List'
//             ? field['SelectedValue']
//             : field['EnteredValue'];

//         if (isCustomMandatory && (value == null || value.toString().isEmpty)) {
//           field['Error'] = 'Please enter ${field['FieldLabel']}';
//           isValid = false;
//         } else {
//           field['Error'] = null;
//         }
//       }
//     });

//     return isValid;
//   }

//   Future<void> _initializeData() async {
//     final now = DateTime.now();
//     final formatted = formatDate(now);

//     controller.fromDateController.text = formatted;
//     controller.toDateController.text = formatted;
//     controller.fetchExchangeRatePerdiem();
//     if (widget.item == null) {
//       await controller.fetchPerDiemRates();
//     }
//     await controller.fetchProjectName();

//     if (widget.item != null) {
//       print("Its Called ");
//       final item = widget.item!;
//       controller.isManualEntry = false;

//       try {
//         final matchedProject = controller.project.firstWhere(
//           (p) => p.code == item.projectId,
//         );
//         controller.selectedProject = matchedProject;
//         controller.projectIdController.text = matchedProject.code;
//       } catch (e) {
//         print("No matching project found for: ${item.projectId}");
//       }

//       try {
//         final matchedLocation = controller.location.firstWhere(
//           (l) => l.location == item.location,
//         );
//         controller.selectedLocationController = item.location!;
//         controller.locationController.text = matchedLocation.location;
//       } catch (e) {
//         print("No matching location found for: ${item.location}");
//       }
//       controller.exchangeamountInController.text = item.totalAmountReporting
//           .toString();
//       controller.fromDateController.text = DateFormat(
//        controller.selectedFormat?.key ?? 'dd/MM/yyyy',
//       ).format(DateTime.fromMillisecondsSinceEpoch(item.fromDate,isUtc: true));
//       controller.toDateController.text = DateFormat(
//        controller.selectedFormat?.key ?? 'dd/MM/yyyy',
//       ).format(DateTime.fromMillisecondsSinceEpoch(item.toDate,isUtc: true));
//       controller.expenseIdController.text = item.expenseId;
//       controller.employeeIdController.text = item.employeeId!;
//       controller.employeeName.text = item.employeeName ?? "";
//       controller.amountInController.text = item.totalAmountReporting.toString();
//       controller.purposeController.text = item.description ?? '';
//       historyFuture = controller.fetchExpenseHistory(item.recId);
//       controller.allocationLines = item.allocationLines;
//       controller.accountingDistributions = item.accountingDistributions;

//       controller.fetchPerDiemRates();
//       controller.fetchExchangeRatePerdiem();
//     }
//     controller.isLoading.value = false;
//   }

//   String formatDate(DateTime date) {
//     return DateFormat(controller.selectedFormat?.key ?? 'dd/MM/yyyy').format(date);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final loc = AppLocalizations.of(context)!;
//     return WillPopScope(
//       onWillPop: () async {
//         controller.clearFormFieldsPerdiem();
//         controller.isEditModePerdiem = false;
//         return true;
//       },
//       child: Scaffold(
//         body: Obx(() {
//           //  if (controller.isLoading.value) {
//           //         return const Padding(
//           //           padding: EdgeInsets.symmetric(vertical: 40),
//           //           child: Center(child: SkeletonLoaderPage()),
//           //         );
//           //       }
//           return Container(
//             decoration: const BoxDecoration(
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(30),
//                 topRight: Radius.circular(30),
//               ),
//             ),
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 10),
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       loc.perDiemDetails,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   if (widget.item != null)
//                     buildTextField(
//                       "${loc.expenseId}*",
//                       controller.expenseIdController,
//                       readOnly: true,
//                     ),
//                   if (widget.item != null)
//                     buildTextField(
//                       "${loc.employeeId} *",
//                       controller.employeeIdController,
//                       readOnly: true,
//                     ),
//                   buildTextField(
//                     "${loc.employeeName} *",
//                     controller.employeeName,
//                     readOnly: true,
//                   ),
//                   ...controller.configList
//                       .where(
//                         (field) =>
//                             field['FieldName'] == 'Project Id' &&
//                             field['IsEnabled'] == true,
//                       )
//                       .map((field) {
//                         final String label = field['FieldName'];
//                         final bool isMandatory = field['IsMandatory'] ?? false;

//                         Widget inputField;

//                         inputField = Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SearchableMultiColumnDropdownField<Project>(
//                               labelText:
//                                   '${loc.projectId} ${isMandatory ? "*" : ""}',
//                               columnHeaders: [loc.projectName, loc.projectId],
//                               enabled: controller.isEditModePerdiem,
//                               controller: controller.projectIdController,
//                               items: controller.project,
//                               selectedValue: controller.selectedProject,
//                               searchValue: (proj) =>
//                                   '${proj.name} ${proj.code}',
//                               displayText: (proj) => proj.code,
//                               onChanged: (proj) {
//                                 setState(() {
//                                   controller.selectedProject = proj;
//                                   controller.selectedProject = proj;

//                                   if (proj != null) {
//                                     _showProjectError = false;
//                                   }
//                                 });
//                               },
//                               rowBuilder: (proj, searchQuery) {
//                                 return Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 12,
//                                     horizontal: 16,
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       SizedBox(width: 10),
//                                       Expanded(child: Text(proj.name)),
//                                       Expanded(child: Text(proj.code)),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             ),
//                             if (_showProjectError)
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 4),
//                                 child: Text(
//                                   loc.pleaseSelectProject,
//                                   style: const TextStyle(
//                                     color: Colors.red,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         );

//                         return Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const SizedBox(height: 8),
//                             inputField,
//                             const SizedBox(height: 16),
//                           ],
//                         );
//                       })
//                       .toList(),
//                   ...controller.configList
//                       .where(
//                         (field) =>
//                             field['FieldName'] == 'Location' &&
//                             field['IsEnabled'] == true,
//                       )
//                       .map((field) {
//                         final bool isMandatory = field['IsMandatory'] ?? false;

//                         return Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SearchableMultiColumnDropdownField<LocationModel>(
//                               labelText:
//                                   '${loc.location} ${isMandatory ? "*" : ""}',
//                               items: controller.location,
//                               selectedValue: controller.selectedLocation,
//                               enabled: controller.isEditModePerdiem,
//                               controller: controller.locationController,
//                               searchValue: (proj) => proj.location,
//                               displayText: (proj) => proj.location,
//                               validator: (proj) => isMandatory && proj == null
//                                   ? loc.selectLocale
//                                   : null,
//                               onChanged: (proj) {
//                                 controller.selectedLocation = proj;
//                                 controller.fetchPerDiemRates();
//                                 loadAndAppendCashAdvanceList();
//                                 field['Error'] = null;
//                               },
//                               columnHeaders: [loc.location, loc.country],
//                               rowBuilder: (proj, searchQuery) {
//                                 return Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 12,
//                                     horizontal: 16,
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Expanded(child: Text(proj.location)),
//                                       Expanded(child: Text(proj.country)),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             ),
//                             if (_showLocationError)
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 4),
//                                 child: Text(
//                                   loc.pleaseSelectLocation,
//                                   style: const TextStyle(
//                                     color: Colors.red,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ),
//                             const SizedBox(height: 14),
//                           ],
//                         );
//                       })
//                       .toList(),

//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       MultiSelectMultiColumnDropdownField<
//                         CashAdvanceDropDownModel
//                       >(
//                         labelText: loc.cashAdvanceRequest,
//                         controller: controller.cashAdvanceIds,
//                         items: controller.cashAdvanceListDropDown,
//                         isMultiSelect: allowMultSelect ?? false,
//                         selectedValue: controller.singleSelectedItem,
//                         selectedValues: controller.multiSelectedItems,
//                         enabled: controller.isEditModePerdiem,
//                         searchValue: (proj) => '${proj.cashAdvanceReqId}',
//                         displayText: (proj) => proj.cashAdvanceReqId,
//                         validator: (proj) => proj == null
//                             ? loc.pleaseSelectCashAdvanceField
//                             : null,
//                         onChanged: (item) {},
//                         onMultiChanged: (items) {},
//                         columnHeaders: [loc.requestId, loc.requestDate],
//                         rowBuilder: (proj, searchQuery) {
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(
//                               vertical: 12,
//                               horizontal: 16,
//                             ),
//                             child: Row(
//                               children: [
//                                 Expanded(child: Text(proj.cashAdvanceReqId)),
//                                 Expanded(
//                                   child: Text(
//                                     controller.formattedDate(proj.requestDate),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 14),
//                       buildDateField(
//                         "${loc.fromDate} *",
//                         controller.fromDateController,
//                         true,
//                         enabled: controller.isEditModePerdiem,
//                       ),
//                       buildDateField(
//                         "${loc.toDate} *",
//                         controller.toDateController,
//                         false,
//                         enabled: controller.isEditModePerdiem,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Expanded(
//                             flex: 3,
//                             child: buildTextField(
//                               "${loc.noOfDays}*",
//                               controller.daysController,
//                               readOnly: true,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           if (widget.item == null ||
//                               controller.isEditModePerdiem)
//                             SizedBox(
//                               width: 50,
//                               child: stylishSettingsButton(
//                                 onPressed: () {
//                                   _showSettingsPopup();
//                                 },
//                               ),
//                             ),
//                         ],
//                       ),
//                       buildTextField(
//                         "${loc.perDiem}*",
//                         controller.perDiemController,
//                         readOnly: true,
//                       ),
//                       buildTextField(
//                         "${loc.totalAmountIN} ${controller.exchangeCurrencyCode.text} *",
//                         controller.exchangeamountInController,
//                         readOnly: true,
//                       ),
//                       buildTextField(
//                         '${loc.totalAmountIN} ${controller.organizationCurrency} *',
//                         controller.amountInController,
//                         readOnly: true,
//                       ),
//                       buildTextField(
//                         loc.purpose,
//                         controller.purposeController,
//                         readOnly: !controller.isEditModePerdiem,
//                       ),
//                       Obx(() {
//                         return Column(
//                           children: controller.customFields.map((field) {
//                             final String label =
//                                 field['FieldLabel'] ?? field['FieldName'];
//                             final bool isMandatory =
//                                 field['IsMandatory'] ?? false;

//                             Widget inputField;

//                             if (field['FieldType'] == 'List') {
//                               inputField = DropdownButtonFormField<String>(
//                                 decoration: InputDecoration(
//                                   labelText: '$label${isMandatory ? " *" : ""}',
//                                   border: const OutlineInputBorder(),
//                                 ),
//                                 value: field['SelectedValue'],
//                                 items:
//                                     (field['Options'] as List<dynamic>?)?.map((
//                                       option,
//                                     ) {
//                                       return DropdownMenuItem<String>(
//                                         value: option.toString(),
//                                         child: Text(option.toString()),
//                                       );
//                                     }).toList() ??
//                                     [],
//                                 onChanged: (value) {
//                                   field['SelectedValue'] = value;
//                                   controller.customFields.refresh();
//                                 },
//                               );
//                             } else {
//                               inputField = TextField(
//                                 decoration: InputDecoration(
//                                   labelText: '$label${isMandatory ? " *" : ""}',
//                                   border: const OutlineInputBorder(),
//                                 ),
//                                 onChanged: (value) {
//                                   field['EnteredValue'] = value;
//                                   controller.customFields.refresh();
//                                 },
//                               );
//                             }

//                             return Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 8),
//                               child: inputField,
//                             );
//                           }).toList(),
//                         );
//                       }),

//                       if (controller.isEditModePerdiem)
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             TextButton(
//                               onPressed: () {
//                                 final double lineAmount =
//                                     double.tryParse(
//                                       controller.amountInController.text,
//                                     ) ??
//                                     0.0;

//                                 if (controller.split.isEmpty &&
//                                     controller
//                                         .accountingDistributions
//                                         .isNotEmpty) {
//                                   controller.split.assignAll(
//                                     controller.accountingDistributions.map((e) {
//                                       return AccountingSplit(
//                                         paidFor: e!.dimensionValueId,
//                                         percentage: e.allocationFactor,
//                                         amount: e.transAmount,
//                                       );
//                                     }).toList(),
//                                   );
//                                 } else if (controller.split.isEmpty) {
//                                   controller.split.add(
//                                     AccountingSplit(percentage: 100.0),
//                                   );
//                                 }

//                                 showModalBottomSheet(
//                                   context: context,
//                                   isScrollControlled: true,
//                                   shape: const RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.vertical(
//                                       top: Radius.circular(16),
//                                     ),
//                                   ),
//                                   builder: (context) => Padding(
//                                     padding: EdgeInsets.only(
//                                       bottom: MediaQuery.of(
//                                         context,
//                                       ).viewInsets.bottom,
//                                       left: 16,
//                                       right: 16,
//                                       top: 24,
//                                     ),
//                                     child: SingleChildScrollView(
//                                       child: AccountingDistributionWidget(
//                                         splits: controller.split,
//                                         lineAmount: lineAmount,
//                                         onChanged: (i, updatedSplit) {
//                                           if (!mounted) return;
//                                           controller.split[i] = updatedSplit;
//                                         },
//                                         onDistributionChanged: (newList) {
//                                           if (!mounted) return;
//                                           controller.accountingDistributions
//                                               .clear();
//                                           controller.accountingDistributions
//                                               .addAll(newList);
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               },
//                               child: Text(loc.accountDistribution),
//                             ),
//                           ],
//                         ),
//                       if (widget.item != null) const SizedBox(height: 10),
//                       if (widget.item != null)
//                         _buildSection(
//                           title: loc.trackingHistory,
//                           children: [
//                             const SizedBox(height: 12),
//                             FutureBuilder<List<ExpenseHistory>>(
//                               future: historyFuture,
//                               builder: (context, snapshot) {
//                                 if (snapshot.connectionState ==
//                                     ConnectionState.waiting) {
//                                   return const Center(
//                                     child: CircularProgressIndicator(),
//                                   );
//                                 }

//                                 if (snapshot.hasError) {
//                                   return Center(
//                                     child: Text(
//                                       "No Data Available Please Skip Next",
//                                     ),
//                                   );
//                                 }

//                                 final historyList = snapshot.data!;
//                                 if (historyList.isEmpty) {
//                                   return Center(
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(16),
//                                       child: Text(
//                                         loc.noHistoryMessage,
//                                         textAlign: TextAlign.center,
//                                         style: const TextStyle(
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 }
//                                 print("historyList: $historyList");
//                                 return ListView.builder(
//                                   shrinkWrap: true,
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   itemCount: historyList.length,
//                                   itemBuilder: (context, index) {
//                                     final item = historyList[index];
//                                     print("Trackingitem: $item");
//                                     return _buildTimelineItem(
//                                       item,
//                                       index == historyList.length - 1,
//                                     );
//                                   },
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                       const SizedBox(height: 20),
//                       const SizedBox(height: 20),

//                       if (widget.item != null &&
//                           widget.item!.stepType == "Review") ...[
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Obx(() {
//                                 bool isLoadingUpdate =
//                                     controller.buttonLoaders['update'] ?? false;
//                                 bool isAnyLoading = controller
//                                     .buttonLoaders
//                                     .values
//                                     .any((loading) => loading == true);

//                                 return ElevatedButton(
//                                   onPressed: (isLoadingUpdate || isAnyLoading)
//                                       ? null
//                                       : () async {
//                                           controller.setButtonLoading(
//                                             'update',
//                                             true,
//                                           );
//                                           try {
//                                             if (validateForm()) {
//                                               await controller
//                                                   .hubperdiemApprovalReview(
//                                                     context,
//                                                     false,
//                                                     widget.item!.workitemrecid,
//                                                     widget.item!.recId
//                                                         .toString(),
//                                                     widget.item!.expenseId
//                                                         .toString(),
//                                                   );
//                                             } else {
//                                               print("Validation failed");
//                                             }
//                                           } finally {
//                                             controller.setButtonLoading(
//                                               'update',
//                                               false,
//                                             );
//                                           }
//                                         },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color.fromARGB(
//                                       255,
//                                       3,
//                                       20,
//                                       117,
//                                     ),
//                                   ),
//                                   child: isLoadingUpdate
//                                       ? const SizedBox(
//                                           width: 20,
//                                           height: 20,
//                                           child: CircularProgressIndicator(
//                                             color: Colors.white,
//                                             strokeWidth: 2,
//                                           ),
//                                         )
//                                       : Text(
//                                           AppLocalizations.of(context)!.update,
//                                           style: const TextStyle(
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                 );
//                               }),
//                             ),
//                             const SizedBox(width: 12),

//                             Expanded(
//                               child: Obx(() {
//                                 bool isLoadingAccept =
//                                     controller.buttonLoaders['updateAccept'] ??
//                                     false;
//                                 bool isAnyLoading = controller
//                                     .buttonLoaders
//                                     .values
//                                     .any((loading) => loading == true);

//                                 return ElevatedButton(
//                                   onPressed: (isLoadingAccept || isAnyLoading)
//                                       ? null
//                                       : () async {
//                                           controller.setButtonLoading(
//                                             'updateAccept',
//                                             true,
//                                           );
//                                           try {
//                                             await controller
//                                                 .hubperdiemApprovalReview(
//                                                   context,
//                                                   true,
//                                                   widget.item!.workitemrecid,
//                                                   widget.item!.recId.toString(),
//                                                   widget.item!.expenseId
//                                                       .toString(),
//                                                 );
//                                           } finally {
//                                             controller.setButtonLoading(
//                                               'updateAccept',
//                                               false,
//                                             );
//                                           }
//                                         },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color.fromARGB(
//                                       255,
//                                       3,
//                                       20,
//                                       117,
//                                     ),
//                                   ),
//                                   child: isLoadingAccept
//                                       ? const SizedBox(
//                                           width: 20,
//                                           height: 20,
//                                           child: CircularProgressIndicator(
//                                             color: Colors.white,
//                                             strokeWidth: 2,
//                                           ),
//                                         )
//                                       : Text(
//                                           AppLocalizations.of(
//                                             context,
//                                           )!.updateAndAccept,
//                                           style: const TextStyle(
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                 );
//                               }),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 12),

//                         Row(
//                           children: [
//                             Expanded(
//                               child: Obx(() {
//                                 bool isLoading =
//                                     controller.buttonLoaders['reject'] ?? false;
//                                 return ElevatedButton(
//                                   onPressed: isLoading
//                                       ? null
//                                       : () async {
//                                           controller.setButtonLoading(
//                                             'reject',
//                                             true,
//                                           );
//                                           try {
//                                             showActionPopup(context, "Reject");
//                                           } finally {
//                                             controller.setButtonLoading(
//                                               'reject',
//                                               false,
//                                             );
//                                           }
//                                         },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color.fromARGB(
//                                       255,
//                                       238,
//                                       20,
//                                       20,
//                                     ),
//                                   ),
//                                   child: isLoading
//                                       ? const SizedBox(
//                                           width: 20,
//                                           height: 20,
//                                           child: CircularProgressIndicator(
//                                             color: Colors.white,
//                                             strokeWidth: 2,
//                                           ),
//                                         )
//                                       : Text(
//                                           AppLocalizations.of(context)!.reject,
//                                           style: const TextStyle(
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                 );
//                               }),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: ElevatedButton(
//                                 onPressed: () {
//                                   controller.skipCurrentItem(
//                                     widget.item!.workitemrecid!,
//                                     context,
//                                   );
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.grey,
//                                 ),
//                                 child: Text(AppLocalizations.of(context)!.skip),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                       const SizedBox(height: 20),
//                       if (widget.item != null &&
//                           widget.item!.stepType == "Approval") ...[
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Obx(() {
//                                 bool isLoading =
//                                     controller.buttonLoaders['approve'] ??
//                                     false;
//                                 return ElevatedButton(
//                                   onPressed: isLoading
//                                       ? null
//                                       : () {
//                                           controller.setButtonLoading(
//                                             'approve',
//                                             true,
//                                           );
//                                           try {
//                                             showActionPopup(context, "Approve");
//                                           } finally {
//                                             controller.setButtonLoading(
//                                               'approve',
//                                               false,
//                                             );
//                                           }
//                                         },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color.fromARGB(
//                                       255,
//                                       30,
//                                       117,
//                                       3,
//                                     ),
//                                   ),
//                                   child: isLoading
//                                       ? const SizedBox(
//                                           width: 20,
//                                           height: 20,
//                                           child: CircularProgressIndicator(
//                                             color: Colors.white,
//                                             strokeWidth: 2,
//                                           ),
//                                         )
//                                       : Text(
//                                           AppLocalizations.of(context)!.approve,
//                                           style: const TextStyle(
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                 );
//                               }),
//                             ),
//                             const SizedBox(width: 12),

//                             Expanded(
//                               child: Obx(() {
//                                 bool isLoading =
//                                     controller.buttonLoaders['reject'] ?? false;
//                                 return ElevatedButton(
//                                   onPressed: isLoading
//                                       ? null
//                                       : () {
//                                           controller.setButtonLoading(
//                                             'reject',
//                                             true,
//                                           );
//                                           try {
//                                             showActionPopup(context, "Reject");
//                                           } finally {
//                                             controller.setButtonLoading(
//                                               'reject',
//                                               false,
//                                             );
//                                           }
//                                         },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color.fromARGB(
//                                       255,
//                                       238,
//                                       20,
//                                       20,
//                                     ),
//                                   ),
//                                   child: isLoading
//                                       ? const SizedBox(
//                                           width: 20,
//                                           height: 20,
//                                           child: CircularProgressIndicator(
//                                             color: Colors.white,
//                                             strokeWidth: 2,
//                                           ),
//                                         )
//                                       : Text(
//                                           AppLocalizations.of(context)!.reject,
//                                           style: const TextStyle(
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                 );
//                               }),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 12),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Obx(() {
//                                 bool isLoading =
//                                     controller.buttonLoaders['escalate'] ??
//                                     false;
//                                 return ElevatedButton(
//                                   onPressed: isLoading
//                                       ? null
//                                       : () {
//                                           controller.setButtonLoading(
//                                             'escalate',
//                                             true,
//                                           );
//                                           try {
//                                             showActionPopup(
//                                               context,
//                                               "Escalate",
//                                             );
//                                           } finally {
//                                             controller.setButtonLoading(
//                                               'escalate',
//                                               false,
//                                             );
//                                           }
//                                         },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color.fromARGB(
//                                       255,
//                                       3,
//                                       20,
//                                       117,
//                                     ),
//                                   ),
//                                   child: isLoading
//                                       ? const SizedBox(
//                                           width: 20,
//                                           height: 20,
//                                           child: CircularProgressIndicator(
//                                             color: Colors.white,
//                                             strokeWidth: 2,
//                                           ),
//                                         )
//                                       : Text(
//                                           AppLocalizations.of(
//                                             context,
//                                           )!.escalate,
//                                           style: const TextStyle(
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                 );
//                               }),
//                             ),
//                             const SizedBox(width: 12),

//                             Expanded(
//                               child: Obx(() {
//                                 final isLoadingClose =
//                                     controller.buttonLoaders['close_review'] ??
//                                     false;
//                                 final isAnyLoading = controller
//                                     .buttonLoaders
//                                     .values
//                                     .any((loading) => loading == true);

//                                 return ElevatedButton(
//                                   onPressed: (isLoadingClose || isAnyLoading)
//                                       ? null
//                                       : () async {
//                                           controller.setButtonLoading(
//                                             'close_review',
//                                             true,
//                                           );
//                                           try {
//                                             controller.skipCurrentItem(
//                                               widget.item!.workitemrecid!,
//                                               context,
//                                             );
//                                           } finally {
//                                             controller.setButtonLoading(
//                                               'close_review',
//                                               false,
//                                             );
//                                           }
//                                         },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.grey,
//                                   ),
//                                   child: isLoadingClose
//                                       ? const CircularProgressIndicator(
//                                           color: Colors.black,
//                                           strokeWidth: 2,
//                                         )
//                                       : Text(
//                                           AppLocalizations.of(context)!.skip,
//                                         ),
//                                 );
//                               }),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                       ],

//                       if (!controller.isEditModePerdiem)
//                         ElevatedButton(
//                           onPressed: () => controller.chancelButton(context),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.grey,
//                           ),
//                           child: const Text(
//                             "Cancel",
//                             style: TextStyle(color: Colors.black),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }

//   Widget buildTextField(
//     String label,
//     TextEditingController controller, {
//     bool readOnly = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 14),
//       child: TextField(
//         controller: controller,
//         readOnly: readOnly,
//         decoration: InputDecoration(
//           labelText: label,
//           filled: true,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//       ),
//     );
//   }

//   Widget buildDateField(
//     String label,
//     TextEditingController controllers,
//     bool isFromDate, {
//     bool enabled = true,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 14),
//       child: GestureDetector(
//         onTap: enabled
//             ? () async {
//                 DateTime initialDate = DateTime.now();

//                 if (controllers.text.trim().isNotEmpty) {
//                   try {
//                     initialDate = DateFormat(
//                      controller.selectedFormat?.key ?? 'dd/MM/yyyy',
//                     ).parseStrict(controllers.text.trim());
//                   } catch (_) {}
//                 }

//                 DateTime firstDate = DateTime(2000);
//                 DateTime lastDate = DateTime.now();

//                 if (!isFromDate &&
//                     controller.fromDateController.text.isNotEmpty) {
//                   try {
//                     firstDate = DateFormat(
//                      controller.selectedFormat?.key ?? 'dd/MM/yyyy',
//                     ).parseStrict(controller.fromDateController.text.trim());
//                   } catch (_) {}
//                 }

//                 final picked = await showDatePicker(
//                   context: context,
//                   initialDate: initialDate,
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime.now(),
//                 );

//                 if (picked != null) {
//                   if (!isFromDate &&
//                       controller.fromDateController.text.isNotEmpty) {
//                     final fromDate = DateFormat(
//                      controller.selectedFormat?.key ?? 'dd/MM/yyyy',
//                     ).parseStrict(controller.fromDateController.text.trim());
//                     if (picked.isBefore(fromDate)) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text(
//                             "To Date cannot be earlier than From Date.",
//                           ),
//                         ),
//                       );
//                       return;
//                     }
//                   }

//                   controllers.text = formatDate(picked);
//                   await controller.fetchPerDiemRates();
//                   controller.fetchExchangeRatePerdiem();
//                   loadAndAppendCashAdvanceList();
//                   if (controller.locationController.text.isNotEmpty) {
//                     loadAndAppendCashAdvanceList();
//                   }
//                 }
//               }
//             : null,
//         child: AbsorbPointer(
//           child: TextField(
//             controller: controllers,
//             readOnly: true,
//             decoration: InputDecoration(
//               labelText: label,
//               filled: true,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               suffixIcon: const Icon(Icons.calendar_today),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSection({
//     required String title,
//     required List<Widget> children,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
//       child: SizedBox(
//         width: double.infinity,
//         child: Card(
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: ExpansionTile(
//             title: Text(
//               title,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//                 color: Colors.deepPurple,
//               ),
//             ),
//             textColor: Colors.deepPurple,
//             iconColor: Colors.deepPurple,
//             collapsedIconColor: Colors.grey,
//             childrenPadding: const EdgeInsets.symmetric(
//               horizontal: 8,
//               vertical: 6,
//             ),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             children: children,
//           ),
//         ),
//       ),
//     );
//   }

//   void showActionPopup(BuildContext context, String status) {
//     final TextEditingController commentController = TextEditingController();
//     bool isCommentError = false;
//     final loc = AppLocalizations.of(context)!;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Padding(
//               padding: MediaQuery.of(context).viewInsets,
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Center(
//                       child: Container(
//                         width: 50,
//                         height: 5,
//                         decoration: BoxDecoration(
//                           color: Colors.grey[400],
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       loc.action,
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     if (status == "Escalate") ...[
//                       Text(
//                         '${loc.selectUser}*',
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                       const SizedBox(height: 8),
//                       Obx(
//                         () => SearchableMultiColumnDropdownField<User>(
//                           labelText: '${loc.user} *',
//                           columnHeaders: [loc.userName, loc.userId],
//                           items: controller.userList,
//                           selectedValue: controller.selectedUser.value,
//                           searchValue: (user) =>
//                               '${user.userName} ${user.userId}',
//                           displayText: (user) => user.userId,
//                           onChanged: (user) {
//                             controller.userIdController.text =
//                                 user?.userId ?? '';
//                             controller.selectedUser.value = user;
//                           },
//                           controller: controller.userIdController,
//                           rowBuilder: (user, searchQuery) {
//                             return Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 vertical: 12,
//                                 horizontal: 16,
//                               ),
//                               child: Row(
//                                 children: [
//                                   Expanded(child: Text(user.userName)),
//                                   Expanded(child: Text(user.userId)),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                     ],
//                     const SizedBox(height: 16),
//                     Text(
//                       '${AppLocalizations.of(context)!.comments} ${status == "Reject" ? "*" : ''}',
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                     const SizedBox(height: 8),
//                     TextField(
//                       controller: commentController,
//                       maxLines: 3,
//                       decoration: InputDecoration(
//                         hintText: loc.enterCommentHere,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide(
//                             color: isCommentError ? Colors.red : Colors.grey,
//                             width: 2,
//                           ),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide(
//                             color: isCommentError ? Colors.red : Colors.teal,
//                             width: 2,
//                           ),
//                         ),
//                         errorText: isCommentError
//                             ? 'Comment is required.'
//                             : null,
//                       ),
//                       onChanged: (value) {
//                         if (isCommentError && value.trim().isNotEmpty) {
//                           setState(() => isCommentError = false);
//                         }
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         TextButton(
//                           onPressed: () {
//                             controller.closeField();
//                             Navigator.pop(context);
//                           },
//                           child: Text(loc.close),
//                         ),
//                         const SizedBox(width: 8),
//                         ElevatedButton(
//                           onPressed: () async {
//                             final comment = commentController.text.trim();
//                             if (status != "Approve" && comment.isEmpty) {
//                               setState(() => isCommentError = true);
//                               return;
//                             }

//                             showDialog(
//                               context: context,
//                               barrierDismissible: false,
//                               builder: (ctx) =>
//                                   const Center(child: SkeletonLoaderPage()),
//                             );

//                             final success = await controller
//                                 .approvalHubpostApprovalAction(
//                                   context,
//                                   workitemrecid: [workitemrecid!],
//                                   decision: status,
//                                   comment: commentController.text,
//                                 );

//                             if (Navigator.of(
//                               context,
//                               rootNavigator: true,
//                             ).canPop()) {
//                               Navigator.of(context, rootNavigator: true).pop();
//                             }

//                             if (!context.mounted) return;

//                             if (success) {
//                               Navigator.pushNamed(
//                                 context,
//                                 AppRoutes.approvalHubMain,
//                               );
//                               controller.isApprovalEnable.value = false;
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('Failed to submit action'),
//                                 ),
//                               );
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.teal,
//                             foregroundColor: Colors.white,
//                           ),
//                           child: Text(status),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 30),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildTimelineItem(ExpenseHistory item, bool isLast) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Column(
//           children: [
//             const Icon(Icons.check_circle, color: Colors.blue),
//             if (!isLast)
//               Container(width: 2, height: 40, color: Colors.grey.shade300),
//           ],
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Card(
//             margin: const EdgeInsets.symmetric(vertical: 8),
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     item.eventType,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(item.notes),
//                   const SizedBox(height: 6),
//                   Text(
//                     'Submitted on ${DateFormat(controller.selectedFormat?.key ?? 'dd/MM/yyyy').format(item.createdDate)}',
//                     style: const TextStyle(color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget stylishSettingsButton({required VoidCallback onPressed}) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.shade400, width: 1),
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.2),
//               blurRadius: 4,
//               offset: const Offset(1, 2),
//             ),
//           ],
//         ),
//         child: const Icon(Icons.settings, size: 18, color: Colors.black87),
//       ),
//     );
//   }

//   Future<void> _showSettingsPopup() async {
//     for (var line in controller.allocationLines) {
//       line.parsed = line.quantity;
//       line.errorText = null;
//     }
//     await showModalBottomSheet(
//       isScrollControlled: true,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       context: context,
//       builder: (_) {
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//           ),
//           child: DraggableScrollableSheet(
//             expand: false,
//             builder: (context, scrollController) {
//               return SingleChildScrollView(
//                 controller: scrollController,
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text(
//                       'Allocation Settings',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     if (controller.allocationLines.isNotEmpty)
//                       ...controller.allocationLines.map(
//                         (line) => _buildAllocationCard(line, isPopup: true),
//                       ),
//                     if (controller.allocationLines.isEmpty)
//                       const Padding(
//                         padding: EdgeInsets.symmetric(vertical: 24),
//                         child: Text(
//                           "No allocation data found for your selected Location. Try another Location.",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(fontSize: 14),
//                         ),
//                       ),
//                     const SizedBox(height: 16),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         ElevatedButton(
//                           onPressed: () => Navigator.of(context).pop(),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.grey[300],
//                             foregroundColor: Colors.black,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 24,
//                               vertical: 12,
//                             ),
//                           ),
//                           child: const Text('Cancel'),
//                         ),
//                         const SizedBox(width: 16),
//                         ElevatedButton(
//                           onPressed: _isSaveButtonEnabled()
//                               ? () {
//                                   for (var data in controller.allocationLines) {
//                                     if (controller.setTheAllcationAmount == 0) {
//                                       controller.setTheAllcationAmount = data
//                                           .unitPriceTrans
//                                           .toInt();
//                                     }
//                                     data.unitPriceTrans =
//                                         controller.setTheAllcationAmount *
//                                         data.parsed;
//                                     data.quantity = data.parsed;
//                                   }

//                                   double updatedTotal = controller
//                                       .allocationLines
//                                       .fold(
//                                         0.0,
//                                         (sum, item) =>
//                                             sum + item.unitPriceTrans,
//                                       );
//                                   controller.amountInController.text =
//                                       updatedTotal.toStringAsFixed(2);

//                                   Navigator.of(context).pop();
//                                 }
//                               : null,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: _isSaveButtonEnabled()
//                                 ? AppColors.gradientEnd
//                                 : Colors.grey,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 24,
//                               vertical: 12,
//                             ),
//                           ),
//                           child: Text(
//                             'Save',
//                             style: TextStyle(
//                               color: _isSaveButtonEnabled()
//                                   ? Colors.white
//                                   : Colors.black45,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   bool _isSaveButtonEnabled() {
//     return controller.allocationLines.every((data) => data.errorText == null);
//   }

//   Widget _buildAllocationCard(AllocationLine data, {bool isPopup = false}) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.blue.shade100),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: _buildReadonlyField(
//                   label: 'Effective From',
//                   value: _formatDate(
//                     DateTime.fromMillisecondsSinceEpoch(data.effectiveFrom,isUtc: true),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: _buildReadonlyField(
//                   label: 'Allowance Category',
//                   value: data.expenseCategoryId,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildReadonlyField(
//                   label: 'Effective To',
//                   value: _formatDate(
//                     DateTime.fromMillisecondsSinceEpoch(data.effectiveTo,isUtc: true),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(child: _buildEditableDaysField(data)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildReadonlyField({required String label, required String value}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(fontSize: 12, color: Colors.black54),
//         ),
//         const SizedBox(height: 4),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: Colors.grey.shade300),
//           ),
//           child: Text(value, style: const TextStyle(fontSize: 14)),
//         ),
//       ],
//     );
//   }

//   Widget _buildEditableDaysField(AllocationLine data) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'No. of Days',
//           style: TextStyle(fontSize: 12, color: Colors.black54),
//         ),
//         const SizedBox(height: 4),
//         SizedBox(
//           width: 110,
//           height: 40,
//           child: TextFormField(
//             initialValue: data.quantity.toString(),
//             keyboardType: TextInputType.number,
//             decoration: InputDecoration(
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 12,
//                 vertical: 10,
//               ),
//               filled: true,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             onChanged: (val) {
//               setState(() {
//                 if (val.isEmpty) {
//                   data.parsed = 0;
//                   data.errorText = "Please enter number of days";
//                 } else {
//                   final parsed = double.tryParse(val);

//                   if (parsed != null) {
//                     if (parsed < 0) {
//                       data.errorText = "Number of days cannot be negative";
//                     } else if (parsed > data.quantity) {
//                       data.errorText =
//                           "Entered days cannot exceed allocated ${data.quantity} day(s)";
//                     } else {
//                       data.errorText = null;
//                       data.parsed = parsed;
//                     }
//                   } else {
//                     data.errorText = "Please enter a valid number";
//                   }
//                 }
//                 _isSaveButtonEnabled();
//               });
//             },
//           ),
//         ),
//         if (data.errorText != null)
//           Padding(
//             padding: const EdgeInsets.only(top: 4),
//             child: Text(
//               data.errorText!,
//               style: const TextStyle(color: Colors.red, fontSize: 12),
//             ),
//           ),
//       ],
//     );
//   }

//   String _formatDate(DateTime dt) {
//     return '${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}/${dt.year}';
//   }
// }
