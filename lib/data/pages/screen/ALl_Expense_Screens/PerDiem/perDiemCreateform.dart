// Full Updated Code with Null Safety Fixes
import 'package:digi_xpense/core/comman/widgets/accountDistribution.dart';
import 'package:digi_xpense/core/comman/widgets/button.dart';
import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';
import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../core/comman/widgets/multiselectDropdown.dart';
import '../../../../../l10n/app_localizations.dart';

class CreatePerDiemPage extends StatefulWidget {
  final bool isReadOnly;
  final PerdiemResponseModel? item;
  const CreatePerDiemPage({super.key, this.item, required this.isReadOnly});

  @override
  State<CreatePerDiemPage> createState() => _CreatePerDiemPageState();
}

class _CreatePerDiemPageState extends State<CreatePerDiemPage>
    with SingleTickerProviderStateMixin {
  final controller = Get.put(Controller());
  bool _showProjectError = false;
  bool _showLocationError = false;
  String? statusApproval;
  late int? workitemrecid;
  bool allowMultSelect = false;
  late Future<List<ExpenseHistory>> historyFuture;

  @override
  void initState() {
    super.initState();

    _initializeDataCashAdvance();
    _loadSettings();

    print("isReadOnly ${widget.isReadOnly}");
    controller.isReadOnly = widget.isReadOnly;

    if (widget.item != null) {
      controller.cashAdvReqIds = widget.item!.cashAdvReqId ?? '';
      statusApproval = widget.item!.approvalStatus ?? 'Unknown';

      if (widget.item!.stepType == "Approval") {
        controller.isEditModePerdiem = false;
        controller.isEditMode = false;
        controller.isReadOnly = true;
      }

      workitemrecid = widget.item!.workitemrecid;

      historyFuture = controller.fetchExpenseHistory(widget.item!.recId);
      controller.split = (widget.item!.accountingDistributions ?? []).map((dist) {
        return AccountingSplit(
          paidFor: dist.dimensionValueId ?? '',
          percentage: dist.allocationFactor ?? 0.0,
          amount: dist.transAmount ?? 0.0,
        );
      }).toList();
    } else {
      statusApproval = 'Unknown';
      workitemrecid = null;
    }

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

      controller.fetchLocation();
      controller.fetchUsers();
      loadAndAppendCashAdvanceList();
      controller.fetchCustomFields();
      controller.configuration();

      await _initializeData();
      if (widget.item == null) {
        controller.fetchPerDiemRates();
      }
    });
  }

  Future<void> _loadSettings() async {
    final settings = await controller.fetchGeneralSettings();
    if (settings != null) {
      setState(() {
        allowMultSelect = settings.allowMultipleCashAdvancesPerExpenseReg;
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

      // Validate Location
      final locationMandatory = isFieldMandatory('Location');
      if (controller.selectedLocation == null && locationMandatory) {
        _showLocationError = true;
        isValid = false;
      } else {
        _showLocationError = false;
      }

      // Validate Custom Fields
      for (var field in controller.customFields) {
        final bool isCustomMandatory =
            (field['IsMandatory'].toString().toLowerCase() == 'true');
        final value = field['FieldType'] == 'List'
            ? field['SelectedValue']
            : field['EnteredValue'];

        if (isCustomMandatory && (value == null || value.toString().isEmpty)) {
          field['Error'] = 'Please enter ${field['FieldLabel']}';
          isValid = false;
        } else {
          field['Error'] = null; // Clear error
        }
      }
    });

    return isValid;
  }

  Future<void> _initializeData() async {
    final now = DateTime.now();
    final formatted = formatDate(now);

    controller.fromDateController.text = formatted;
    controller.toDateController.text = formatted;
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([controller.fetchProjectName()]);
    });
    
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
          // orElse: () => LocationModel(location: '', country: ''), // Safe fallback
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

      // Safe date handling
      if (item.fromDate != null) {
        controller.fromDateController.text = DateFormat('dd-MMM-yyyy')
            .format(DateTime.fromMillisecondsSinceEpoch(item.fromDate!));
      }
      
      if (item.toDate != null) {
        controller.toDateController.text = DateFormat('dd-MMM-yyyy')
            .format(DateTime.fromMillisecondsSinceEpoch(item.toDate!));
      }
      
      controller.expenseIdController.text = item.expenseId ?? '';
      controller.employeeIdController.text = item.employeeId ?? '';
      controller.employeeName.text = item.employeeName ?? ''; // ✅ Safe null handling
      controller.daysController.text = (item.noOfDays ?? 0).toString();
      
      await controller.fetchPerDiemRates();
      controller.amountInController.clear();
      controller.allocationLines.clear();
      controller.amountInController.text = (item.totalAmountReporting ?? 0.0).toString();
      controller.exchangeamountInController.text = (item.totalAmountTrans ?? 0.0).toString();
      controller.purposeController.text = item.description ?? '';

      historyFuture = controller.fetchExpenseHistory(item.recId);

      controller.allocationLines.clear();
      controller.allocationLines = item.allocationLines ?? [];
      for (var item in controller.allocationLines) {
        controller.perDiemController.text = item.perDiemId ?? '';
      }

      print("allocationLinesData ${controller.allocationLines.map((e) => e.toJson()).toList()}");
      controller.accountingDistributions = item.accountingDistributions ?? [];
      controller.isLoadingGE2.value = false;
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd-MMM-yyyy').format(date);
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
    
    if (controller.expenseIdController.text.isEmpty && widget.item != null) {
      controller.isLoadingGE2.value = true;
    } else {
      controller.isLoadingGE2.value = false;
    }
    
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
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text(
            widget.item == null
                ? loc.createPerDiem
                : controller.isEditModePerdiem
                    ? loc.editPerDiem
                    : loc.viewPerDiem,
          ),
          actions: [
            if (!controller.isReadOnly)
              if (!widget.isReadOnly &&
                  widget.item != null &&
                  widget.item!.approvalStatus != "Approved" &&
                  widget.item!.approvalStatus != "Cancelled")
                IconButton(
                  icon: Icon(
                    controller.isEditModePerdiem
                        ? Icons.remove_red_eye
                        : Icons.edit_document,
                  ),
                  onPressed: () {
                    setState(() {
                      controller.isEditModePerdiem = !controller.isEditModePerdiem;
                    });
                  },
                ),
          ],
        ),
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
                                  debugPrint("Status: $statusApproval");
                                },
                                icon: const Icon(
                                  Icons.donut_large,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  statusApproval ?? 'Unknown', // ✅ Safe null handling
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
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                            "${loc.expenseId}*",
                            controller.expenseIdController,
                            readOnly: true,
                          ),
                        if (widget.item != null)
                          buildTextField(
                            "${loc.employeeId} *",
                            controller.employeeIdController,
                            readOnly: true,
                          ),
                        if (widget.item != null)
                          buildTextField(
                            "${loc.employeeName} *",
                            controller.employeeName,
                            readOnly: true,
                          ),
                        ...controller.configList
                            .where(
                              (field) =>
                                  field['FieldName'] == 'Project Id' &&
                                  field['IsEnabled'] == true,
                            )
                            .map((field) {
                              final String label = field['FieldName'];
                              final bool isMandatory = field['IsMandatory'] ?? false;

                              Widget inputField;

                              inputField = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SearchableMultiColumnDropdownField<Project>(
                                    labelText: '${loc.projectId} ${isMandatory ? "*" : ""}',
                                    columnHeaders: [
                                      loc.projectName,
                                      loc.projectId,
                                    ],
                                    enabled: controller.isEditModePerdiem,
                                    controller: controller.projectIdController,
                                    items: controller.project,
                                    selectedValue: controller.selectedProject,
                                    searchValue: (proj) => '${proj.name} ${proj.code}',
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
                              final bool isMandatory = field['IsMandatory'] ?? false;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SearchableMultiColumnDropdownField<LocationModel>(
                                    labelText: '${loc.location} ${isMandatory ? "*" : ""}',
                                    items: controller.location,
                                    selectedValue: controller.selectedLocation,
                                    enabled: controller.isEditModePerdiem,
                                    controller: controller.locationController,
                                    searchValue: (proj) => proj.location,
                                    displayText: (proj) => proj.location,
                                    validator: (proj) => isMandatory && proj == null
                                        ? loc.selectLocale
                                        : null,
                                    onChanged: (proj) async {
                                      controller.selectedLocation = proj;
                                      if (proj != null) {
                                        controller.selectedLocationController = proj.location;
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
                                            Expanded(child: Text(proj.location)),
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
                                  const SizedBox(height: 12),
                                ],
                              );
                            })
                            .toList(),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MultiSelectMultiColumnDropdownField<CashAdvanceDropDownModel>(
                              labelText: loc.cashAdvanceRequest,
                              items: controller.cashAdvanceListDropDown,
                              isMultiSelect: allowMultSelect ?? false,
                              selectedValue: controller.singleSelectedItem,
                              selectedValues: controller.multiSelectedItems,
                              enabled: controller.isEditModePerdiem,
                              searchValue: (proj) => '${proj.cashAdvanceReqId}',
                              displayText: (proj) => proj.cashAdvanceReqId,
                              validator: (proj) => proj == null
                                  ? loc.pleaseSelectCashAdvanceField
                                  : null,
                              onChanged: (item) {
                                controller.cashAdvanceIds.text = item.toString();
                              },
                              onMultiChanged: (items) {},
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
                                      Expanded(child: Text(proj.cashAdvanceReqId)),
                                      Expanded(
                                        child: Text(
                                          controller.formattedDate(proj.requestDate),
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
                                    readOnly: true,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (widget.item == null || controller.isEditModePerdiem)
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
                              readOnly: true,
                            ),
                            buildTextField(
                              "${loc.totalAmount} ${controller.exchangeCurrencyCode.text}*",
                              controller.exchangeamountInController,
                              readOnly: true,
                            ),
                            buildTextField(
                              loc.totalAmountInInr,
                              controller.amountInController,
                              readOnly: true,
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
                                children: controller.customFields.map((field) {
                                  final String label = field['FieldLabel'] ?? field['FieldName'];
                                  final bool isMandatory = field['IsMandatory'] ?? false;

                                  Widget inputField;

                                  if (field['FieldType'] == 'List') {
                                    if (field['Options'] == null || field['Options'].isEmpty) {
                                      controller.fetchCustomFieldValues(field['FieldId']);
                                    }

                                    inputField = SearchableMultiColumnDropdownField<CustomDropdownValue>(
                                      labelText: '$label${isMandatory ? " *" : ""}',
                                      items: (field['Options'] as List<CustomDropdownValue>?) ?? [],
                                      selectedValue: field['SelectedValue'],
                                      searchValue: (val) => val.valueName,
                                      enabled: controller.isEditModePerdiem,
                                      displayText: (val) => val.valueName,
                                      columnHeaders: const ['Value ID', 'Value Name'],
                                      rowBuilder: (val, searchQuery) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                        child: Row(
                                          children: [
                                            Expanded(child: Text(val.valueId)),
                                            Expanded(child: Text(val.valueName)),
                                          ],
                                        ),
                                      ),
                                      validator: (val) =>
                                          isMandatory && val == null ? 'Please select a value' : null,
                                      onChanged: (val) {
                                        field['SelectedValue'] = val;
                                        field['Error'] = null;
                                        controller.customFields.refresh();
                                      },
                                    );
                                  } else {
                                    inputField = TextField(
                                      enabled: controller.isEditModePerdiem,
                                      decoration: InputDecoration(
                                        labelText: '$label${isMandatory ? " *" : ""}',
                                        border: const OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        field['EnteredValue'] = value;
                                        controller.customFields.refresh();
                                      },
                                    );
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: inputField,
                                  );
                                }).toList(),
                              );
                            }),

                            if (controller.isEditModePerdiem)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      final double lineAmount = double.tryParse(
                                            controller.amountInController.text,
                                          ) ??
                                          0.0;

                                      if (controller.split.isEmpty &&
                                          controller.accountingDistributions.isNotEmpty) {
                                        controller.split.assignAll(
                                          controller.accountingDistributions.map((e) {
                                                return AccountingSplit(
                                                  paidFor: e?.dimensionValueId ?? '',
                                                  percentage: e?.allocationFactor ?? 0.0,
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
                                                controller.accountingDistributions.addAll(newList);
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
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
  if (snapshot.hasError) {
                                          return Center(
                                            child: Text(
                                              "No Data Available",
                                            ),
                                          );
                                        }

                                      final historyList = snapshot.data ?? [];
                                      if (historyList.isEmpty) {
                                        return Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Text(
                                              loc.noHistoryMessage,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(color: Colors.grey),
                                            ),
                                          ),
                                        );
                                      }
                                      print("historyList: $historyList");
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

                            // Submit Button for new PerDiem
                            if (controller.isEditModePerdiem && widget.item == null) ...[
                              const SizedBox(height: 20),
                              Obx(() {
                                bool isLoading = controller.buttonLoaders['submit'] ?? false;
                                return SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () async {
                                            controller.setButtonLoading('submit', true);
                                            try {
                                              if (validateForm()) {
                                                await controller.updatePerDiemDetails(
                                                  context,
                                                  true,
                                                  false,
                                                  null,
                                                );
                                              } else {
                                                print("Validation failed");
                                              }
                                            } finally {
                                              controller.setButtonLoading('submit', false);
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 2, 21, 131),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            loc.submit,
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Obx(() {
                                      bool isLoading = controller.buttonLoaders['save'] ?? false;
                                      return ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : () async {
                                                controller.setButtonLoading('save', true);
                                                try {
                                                  if (validateForm()) {
                                                    await controller.updatePerDiemDetails(
                                                      context,
                                                      false,
                                                      false,
                                                      null,
                                                    );
                                                  } else {
                                                    print("Validation failed");
                                                  }
                                                } finally {
                                                  controller.setButtonLoading('save', false);
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(255, 13, 138, 2),
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                loc.save,
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => {controller.chancelButton(context),
                                      controller.closeField()},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey,
                                      ),
                                      child: Text(loc.cancel), 
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // Cancel & Close Buttons (Pending approval)
                            if (widget.item != null && controller.isEditModePerdiem &&
                                widget.item!.stepType == null && widget.item!.expenseStatus == "Verified")
                              Row(
                                children: [
                                  Expanded(
                                    child: Obx(() {
                                      bool isLoading = controller.buttonLoaders['cancel'] ?? false;
                                      return ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : () async {
                                                controller.setButtonLoading('cancel', true);
                                                try {
                                                  await controller.cancelExpense(
                                                    context,
                                                    widget.item!.recId.toString(),
                                                  );
                                                } finally {
                                                  controller.setButtonLoading('cancel', false);
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(255, 233, 151, 151),
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  color: Colors.red,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                loc.cancel,
                                                style: const TextStyle(color: Colors.red),
                                              ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => {controller.chancelButton(context),
                                      controller.closeField()},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey,
                                      ),
                                      child: Text(
                                        loc.close,
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            // Update & Accept buttons for Review step
                            if (controller.isEditModePerdiem && widget.item != null && widget.item!.stepType == "Review") ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: Obx(() {
                                      bool isLoadingUpdate = controller.buttonLoaders['update'] ?? false;
                                      bool isAnyLoading = controller.buttonLoaders.values.any((loading) => loading == true);
                                      return ElevatedButton(
                                        onPressed: (isLoadingUpdate || isAnyLoading)
                                            ? null
                                            : () async {
                                                controller.setButtonLoading('update', true);
                                                try {
                                                  if (validateForm()) {
                                                    await controller.perdiemApprovalReview(
                                                      context,
                                                      false,
                                                      widget.item!.workitemrecid,
                                                      widget.item!.recId.toString(),
                                                      widget.item!.expenseId.toString(),
                                                    );
                                                  } else {
                                                    print("Validation failed");
                                                  }
                                                } finally {
                                                  controller.setButtonLoading('update', false);
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(255, 3, 20, 117),
                                        ),
                                        child: isLoadingUpdate
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                loc.update,
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Obx(() {
                                      bool isLoadingAccept = controller.buttonLoaders['updateAccept'] ?? false;
                                      bool isAnyLoading = controller.buttonLoaders.values.any((loading) => loading == true);
                                      return ElevatedButton(
                                        onPressed: (isLoadingAccept || isAnyLoading)
                                            ? null
                                            : () async {
                                                controller.setButtonLoading('updateAccept', true);
                                                try {
                                                  await controller.perdiemApprovalReview(
                                                    context,
                                                    true,
                                                    widget.item!.workitemrecid,
                                                    widget.item!.recId.toString(),
                                                    widget.item!.expenseId.toString(),
                                                  );
                                                } finally {
                                                  controller.setButtonLoading('updateAccept', false);
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(255, 3, 20, 117),
                                        ),
                                        child: isLoadingAccept
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                loc.updateAndAccept,
                                                style: const TextStyle(color: Colors.white),
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
                                      bool isLoading = controller.buttonLoaders['reject'] ?? false;
                                      return ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : () async {
                                                controller.setButtonLoading('reject', true);
                                                try {
                                                  showActionPopup(context, "Reject");
                                                } finally {
                                                  controller.setButtonLoading('reject', false);
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(255, 238, 20, 20),
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                loc.reject,
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => {controller.chancelButton(context),
                                      controller.closeField()},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey,
                                      ),
                                      child: Text(
                                        loc.close,
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // Submit Button for Created status
                            if (controller.isEditModePerdiem && widget.item != null && widget.item!.approvalStatus == "Created")
                              Obx(() {
                                bool isLoadingSubmit = controller.buttonLoaders['submit'] ?? false;
                                bool isAnyLoading = controller.buttonLoaders.values.any((loading) => loading == true);
                                return SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: (isLoadingSubmit || isAnyLoading)
                                        ? null
                                        : () {
                                            if (validateForm()) {
                                              controller.setButtonLoading('submit', true);
                                              controller.updatePerDiemDetails(
                                                context,
                                                true,
                                                false,
                                                widget.item!.recId,
                                                widget.item!.expenseId,
                                              ).whenComplete(
                                                () => controller.setButtonLoading('submit', false),
                                              );
                                            } else {
                                              print("Validation failed");
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      backgroundColor: const Color.fromARGB(255, 2, 19, 114),
                                    ),
                                    child: isLoadingSubmit
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
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

                            // Save & Cancel for Created status
                            if (controller.isEditModePerdiem && widget.item != null && widget.item!.approvalStatus == "Created") ...[
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: Obx(() {
                                      bool isLoadingSave = controller.buttonLoaders['save'] ?? false;
                                      bool isAnyLoading = controller.buttonLoaders.values.any((loading) => loading == true);
                                      return ElevatedButton(
                                        onPressed: (isLoadingSave || isAnyLoading)
                                            ? null
                                            : () {
                                                if (validateForm()) {
                                                  controller.setButtonLoading('save', true);
                                                  controller.updatePerDiemDetails(
                                                    context,
                                                    false,
                                                    false,
                                                    widget.item!.recId,
                                                    widget.item!.expenseId,
                                                  ).whenComplete(
                                                    () => controller.setButtonLoading('save', false),
                                                  );
                                                } else {
                                                  print("Validation failed");
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(255, 28, 114, 2),
                                        ),
                                        child: isLoadingSave
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                loc.save,
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Obx(() {
                                      bool isLoadingCancel = controller.buttonLoaders['cancel'] ?? false;
                                      bool isAnyLoading = controller.buttonLoaders.values.any((loading) => loading == true);
                                      return ElevatedButton(
                                        onPressed: (isLoadingCancel || isAnyLoading)
                                            ? null
                                            : () {
                                                controller.setButtonLoading('cancel', true);
                                                Future.delayed(
                                                  const Duration(milliseconds: 500),
                                                  () {
                                                    controller.chancelButton(context);
                                                    controller.setButtonLoading('cancel', false);
                                                  },
                                                );
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey,
                                        ),
                                        child: isLoadingCancel
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(loc.cancel),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ],

                            // Resubmit for Rejected status
                            if (controller.isEditModePerdiem && widget.item != null && widget.item!.approvalStatus == "Rejected")
                              Column(
                                children: [
                                  Obx(() {
                                    bool isLoadingResubmit = controller.buttonLoaders['resubmit'] ?? false;
                                    bool isAnyLoading = controller.buttonLoaders.values.any((loading) => loading == true);
                                    return SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: (isLoadingResubmit || isAnyLoading)
                                            ? null
                                            : () {
                                                if (validateForm()) {
                                                  controller.setButtonLoading('resubmit', true);
                                                  controller.updatePerDiemDetails(
                                                    context,
                                                    true,
                                                    true,
                                                    widget.item!.recId,
                                                    widget.item!.expenseId.toString(),
                                                  ).whenComplete(
                                                    () => controller.setButtonLoading('resubmit', false),
                                                  );
                                                } else {
                                                  print("Validation failed");
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(255, 4, 2, 114),
                                        ),
                                        child: isLoadingResubmit
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                loc.resubmit,
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Obx(() {
                                          bool isLoadingUpdate = controller.buttonLoaders['update'] ?? false;
                                          bool isAnyLoading = controller.buttonLoaders.values.any((loading) => loading == true);
                                          return ElevatedButton(
                                            onPressed: (isLoadingUpdate || isAnyLoading)
                                                ? null
                                                : () {
                                                    if (validateForm()) {
                                                      controller.setButtonLoading('update', true);
                                                      controller.updatePerDiemDetails(
                                                        context,
                                                        false,
                                                        false,
                                                        widget.item!.recId,
                                                        widget.item!.expenseId.toString(),
                                                      ).whenComplete(
                                                        () => controller.setButtonLoading('update', false),
                                                      );
                                                    } else {
                                                      print("Validation failed");
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color.fromARGB(255, 20, 94, 2),
                                            ),
                                            child: isLoadingUpdate
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : Text(
                                                    loc.update,
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                          );
                                        }),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Obx(() {
                                          bool isAnyLoading = controller.buttonLoaders.values.any((loading) => loading == true);
                                          return ElevatedButton(
                                            onPressed: isAnyLoading
                                                ? null
                                                : () => {controller.chancelButton(context),
                                      controller.closeField()},
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey,
                                            ),
                                            child: Text(
                                              loc.close,
                                              style: const TextStyle(color: Colors.black),
                                            ),
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                            // Approval buttons
                            if (!controller.isEditMode && widget.item != null && widget.item!.stepType == "Approval") ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: Obx(() {
                                      bool isLoading = controller.buttonLoaders['approve'] ?? false;
                                      return ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : () {
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
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                loc.approvals,
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Obx(() {
                                      bool isLoading = controller.buttonLoaders['reject'] ?? false;
                                      return ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : () {
                                                controller.setButtonLoading('reject', true);
                                                try {
                                                  showActionPopup(context, "Reject");
                                                } finally {
                                                  controller.setButtonLoading('reject', false);
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(255, 238, 20, 20),
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                loc.reject,
                                                style: const TextStyle(color: Colors.white),
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
                                      bool isLoading = controller.buttonLoaders['escalate'] ?? false;
                                      return ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : () {
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
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                loc.escalate,
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Obx(() {
                                      bool isLoading = controller.buttonLoaders['close'] ?? false;
                                      return ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : () {
                                                controller.setButtonLoading('close', true);
                                                Future.delayed(
                                                  const Duration(milliseconds: 500),
                                                  () {
                                                    controller.chancelButton(context);
                                                    controller.setButtonLoading('close', false);
                                                    controller.closeField();
                                                  },
                                                );
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey,
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                loc.close,
                                                style: const TextStyle(color: Colors.black),
                                              ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ],

                            // Close button for view mode
                            if (controller.isEditMode && widget.item != null && !controller.isEditModePerdiem)
                              ElevatedButton(
                                onPressed: () => {controller.chancelButton(context),
                                      controller.closeField()},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                ),
                                child: Text(
                                  loc.close,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
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
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                DateTime initialDate = DateTime.now();

                if (controllers.text.trim().isNotEmpty) {
                  try {
                    initialDate = DateFormat('dd-MMM-yyyy').parseStrict(controllers.text.trim());
                  } catch (_) {}
                }

                DateTime firstDate = DateTime(2000);
                DateTime lastDate = DateTime.now();

                if (!isFromDate && controller.fromDateController.text.isNotEmpty) {
                  try {
                    firstDate = DateFormat('dd-MMM-yyyy').parseStrict(controller.fromDateController.text.trim());
                  } catch (_) {}
                }

                final picked = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: firstDate,
                  lastDate: lastDate,
                );

                if (picked != null) {
                  if (!isFromDate && controller.fromDateController.text.isNotEmpty) {
                    final fromDate = DateFormat('dd-MMM-yyyy').parseStrict(controller.fromDateController.text.trim());
                    if (picked.isBefore(fromDate)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("To Date cannot be earlier than From Date."),
                        ),
                      );
                      return;
                    }
                  }

                  controllers.text = formatDate(picked);
                  await controller.fetchPerDiemRates();
                  controller.fetchExchangeRatePerdiem();

                  if (controller.locationController.text.isNotEmpty) {
                    loadAndAppendCashAdvanceList();
                  }
                }
              }
            : null,
        child: AbsorbPointer(
          child: TextField(
            controller: controllers,
            readOnly: true,
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
                          searchValue: (user) => '${user.userName} ${user.userId}',
                          displayText: (user) => user.userId,
                          onChanged: (user) {
                            controller.userIdController.text = user?.userId ?? '';
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
                    Text(loc.comments, style: const TextStyle(fontSize: 16)),
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
                        errorText: isCommentError ? 'Comment is required.' : null,
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
                              builder: (ctx) => const Center(child: SkeletonLoaderPage()),
                            );

                            final success = await controller.postApprovalAction(
                              context,
                              workitemrecid: workitemrecid != null ? [workitemrecid!] : [], // ✅ Safe null handling
                              decision: status,
                              comment: commentController.text,
                            );

                            if (Navigator.of(context, rootNavigator: true).canPop()) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }

                            if (!context.mounted) return;

                            if (success) {
                              Navigator.pushNamed(context, AppRoutes.approvalDashboard);
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
                    '${loc.submittedOn} ${DateFormat('dd/MM/yyyy').format(item.createdDate)}',
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
                                  controller.setTheAllcationAmount = 0.0.toInt();

                                  if (controller.initialUnitPriceTrans == null ||
                                      controller.initialUnitPriceTrans!.length != controller.allocationLines.length) {
                                    controller.initialUnitPriceTrans = controller.allocationLines
                                        .map((data) => data.unitPriceTrans)
                                        .toList();
                                  }

                                  for (int i = 0; i < controller.allocationLines.length; i++) {
                                    var data = controller.allocationLines[i];
                                    double initialUnitPrice = controller.initialUnitPriceTrans![i];

                                    print('Before: unitPrice=$initialUnitPrice, parsed=${data.parsed}');
                                    print('Before: setTheAllcationAmount=${controller.setTheAllcationAmount}, parsed=${data.parsed}');

                                    data.unitPriceTrans = initialUnitPrice * data.parsed;
                                    data.quantity = data.parsed;
                                  }

                                  controller.paidAmount.text = controller.amountInController.text;
                                  double updatedTotal = controller.allocationLines.fold(
                                    0.0,
                                    (sum, item) => sum + item.unitPriceTrans,
                                  );

                                  if (_isSaveButtonEnabled()) {
                                    controller.amountInController.text = updatedTotal.toStringAsFixed(2);
                                    controller.exchangeamountInController.text = updatedTotal.toStringAsFixed(2);
                                  }
                                  print("amountInController${controller.amountInController.text}");
                                  controller.fetchExchangeRatePerdiem();

                                  if (_isSaveButtonEnabled()) {
                                    Navigator.of(context).pop();
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: "No of Days Not Valid",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: const Color.fromARGB(255, 250, 1, 1),
                                      textColor: const Color.fromARGB(255, 212, 210, 241),
                                      fontSize: 16.0,
                                    );
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSaveButtonEnabled() ? AppColors.gradientEnd : Colors.grey,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            loc.save,
                            style: TextStyle(
                              color: _isSaveButtonEnabled() ? Colors.white : Colors.black45,
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
                  value: _formatDate(DateTime.fromMillisecondsSinceEpoch(data.effectiveFrom)),
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
                  value: _formatDate(DateTime.fromMillisecondsSinceEpoch(data.effectiveTo)),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  final totalDays = double.tryParse(controller.daysController.text);
                  if (parsed != null) {
                    if (parsed < 0) {
                      data.errorText = loc.numberOfDaysCannotBeNegative;
                    } else if (parsed > (totalDays ?? 0)) {
                      data.errorText = "${loc.enteredDaysCannotExceedAllocated} $totalDays";
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