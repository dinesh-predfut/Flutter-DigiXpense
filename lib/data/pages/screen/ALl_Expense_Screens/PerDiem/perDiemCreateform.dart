// Full Updated Code with View/Edit Mode Toggle and Date Pickers
import 'package:digi_xpense/core/comman/widgets/accountDistribution.dart';
import 'package:digi_xpense/core/comman/widgets/button.dart';
import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';
import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
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
  late final int workitemrecid;
  bool allowMultSelect = false;
  late Future<List<ExpenseHistory>> historyFuture;
  @override
  void initState() {
    super.initState();
    if (widget.item == null) {
      controller.fetchPerDiemRates();
    }
    controller.fetchCustomFields();
    controller.configuration();
    controller.getUserPref();
    // loadAndAppendCashAdvanceList();

    _initializeDataCashAdvance();
    _loadSettings();

    print("isReadOnly${widget.isReadOnly}");
    if (widget.item == null) {
      setState(() {
        controller.isEditModePerdiem = true;
      });
    }
    controller.isReadOnly = widget.isReadOnly;
    // controller.clearFormFieldsPerdiem();
    if (widget.item != null) {
      setState(() {
        controller.isEditModePerdiem = false;
      });
      controller.cashAdvReqIds = widget.item!.cashAdvReqId;
      if (widget.item!.stepType != null &&
          widget.item!.stepType == "Approval") {
        setState(() {
          controller.isEditModePerdiem = false;
          controller.isEditMode = false;
          controller.isReadOnly = true;
        });
      }
      if (widget.item!.workitemrecid != null) {
        workitemrecid = widget.item!.workitemrecid!;
      }

      historyFuture = controller.fetchExpenseHistory(widget.item!.recId);
      controller.split =
          (widget.item!.accountingDistributions ?? []).map((dist) {
        return AccountingSplit(
          paidFor: dist.dimensionValueId ?? '',
          percentage: dist.allocationFactor ?? 0.0,
          amount: dist.transAmount ?? 0.0,
        );
      }).toList();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.fetchLocation();
      controller.fetchUsers();
      loadAndAppendCashAdvanceList();

      await _initializeData();
      if (widget.item == null) {
        controller.fetchPerDiemRates();
      }

      if (widget.item != null) {
        // controller.isEditModePerdiem = widget.item != null;
      }
    });
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
      // Validate Tax Amount

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
    controller.isLoadingGE2.value = true;
    final now = DateTime.now();
    final formatted = formatDate(now);

    controller.fromDateController.text = formatted;
    controller.toDateController.text = formatted;
    if (widget.item == null) {
      await Future.wait([
        // controller.fetchProjectName(),
      ]);
    }
    await Future.wait([
      controller.fetchProjectName(),
    ]);

    if (widget.item != null) {
      // controller.isLoadingGE2.value = true;
      print("Its Called ");
      final item = widget.item!;
      controller.isManualEntry = true;
      final matchedProject = controller.project.firstWhere(
        (p) => p.code == item.projectId,
        orElse: () => Project(name: '', code: '', isNotEmpty: true),
      );

      if (matchedProject.code.isNotEmpty) {
        controller.selectedProject = matchedProject;
        controller.projectIdController.text = matchedProject.code;
      }

      final matchedLocation = controller.location.firstWhere(
        (l) => l.location == item.location,
        // orElse: () => LocationModel(location: '', country: ''),
      );

      controller.selectedLocation = matchedLocation;
      controller.locationController.text = matchedLocation.location;

      controller.fromDateController.text = DateFormat('dd-MMM-yyyy')
          .format(DateTime.fromMillisecondsSinceEpoch(item.fromDate));
      controller.toDateController.text = DateFormat('dd-MMM-yyyy')
          .format(DateTime.fromMillisecondsSinceEpoch(item.toDate));
      controller.expenseIdController.text = item.expenseId;
      controller.employeeIdController.text = item.employeeId!;
      controller.daysController.text = item.noOfDays.toString();
      await controller.fetchPerDiemRates();
      controller.amountInController.clear();
      controller.allocationLines.clear();
      controller.amountInController.text = item.totalAmountReporting.toString();
      controller.exchangeamountInController.text =
          item.totalAmountTrans.toString();
      controller.purposeController.text = item.description ?? '';

      historyFuture = controller.fetchExpenseHistory(item.recId);

      controller.allocationLines.clear();
      controller.allocationLines = item.allocationLines;
      for (var item in controller.allocationLines) {
        // item.per = perDiemController.PerDiemId;
        controller.perDiemController.text = item.perDiemId;
      }

      print(
          "allocationLinesData ${controller.allocationLines.map((e) => e.toJson()).toList()}");
      controller.accountingDistributions = item.accountingDistributions;
      // controller.fetchExchangeRatePerdiem();
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
    String? backendSelectedIds =
        controller.cashAdvReqIds; // Replace with actual backend response
    print("preloadCashAdvanceSelections$backendSelectedIds");
    controller.preloadCashAdvanceSelections(
        controller.cashAdvanceListDropDown, backendSelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    // ignore: deprecated_member_use
    return WillPopScope(
        onWillPop: () async {
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit Form'),
              content: const Text(
                'You will lose any unsaved data. Do you want to exit?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // Stay
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(true), // Confirm exit
                  child: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );

          if (shouldExit ?? false) {
            controller.clearFormFieldsPerdiem();
            controller.isEditModePerdiem = true;

            // Optional: If you want to navigate to a specific route, uncomment this:
            // Navigator.popUntil(context, ModalRoute.withName(AppRoutes.dashboard_Main));

            return true; // allow back navigation
          }

          return false; // cancel back navigation
        },
        child: Scaffold(
            // backgroundColor: primaryColor,
            appBar: AppBar(
              backgroundColor: primaryColor,
              title: Text(
                widget.item == null
                    ? loc.createPerDiem
                    : controller.isEditModePerdiem
                        ? loc.editPerDiem
                        : loc.viewPerDiem,
                // style: const TextStyle(color: Colors.white),
              ),
              // iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                if (!controller.isReadOnly)
                  if (!widget.isReadOnly &&
                      widget.item != null &&
                      widget.item!.approvalStatus != "Approved")
                    IconButton(
                      icon: Icon(
                        controller.isEditModePerdiem
                            ? Icons.remove_red_eye
                            : Icons.edit_document,
                      ),
                      onPressed: () {
                        setState(() {
                          controller.isEditModePerdiem =
                              !controller.isEditModePerdiem;
                        });
                      },
                    )
              ],
            ),
            body: Obx(() {
              return controller.isLoadingGE2.value
                  ? const SkeletonLoaderPage()
                  : Container(
                      decoration: const BoxDecoration(
                        // color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                loc.perDiemDetails,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            if (widget.item != null)
                              buildTextField("${loc.expenseId}*",
                                  controller.expenseIdController,
                                  readOnly: true),
                            if (widget.item != null)
                              buildTextField("${loc.employeeId} *",
                                  controller.employeeIdController,
                                  readOnly: true),
                            ...controller.configList
                                .where((field) =>
                                    field['FieldName'] == 'Project Id' &&
                                    field['FieldName'] !=
                                        'Location') // 👈 filter only Project Id
                                .map((field) {
                              final String label = field['FieldName'];
                              final bool isMandatory =
                                  field['IsMandatory'] ?? false;

                              Widget inputField;

                              // Project dropdown logic
                              inputField = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SearchableMultiColumnDropdownField<Project>(
                                    labelText:
                                        '${loc.projectId} ${isMandatory ? "*" : ""}',
                                    columnHeaders: [
                                      loc.projectName,
                                      loc.projectId
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
                                        controller.selectedProject = proj;

                                        if (proj != null) {
                                          _showProjectError = false;
                                        }
                                      });
                                    },
                                    rowBuilder: (proj, searchQuery) {
                                      Widget highlight(String text) {
                                        final lowerQuery =
                                            searchQuery.toLowerCase();
                                        final lowerText = text.toLowerCase();
                                        final start =
                                            lowerText.indexOf(lowerQuery);
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
                                                text:
                                                    text.substring(start, end),
                                                style: const TextStyle(
                                                  color: Colors.blue,
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
                                                child: highlight(proj.name)),
                                            Expanded(
                                                child: highlight(proj.code)),
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
                                            color: Colors.red, fontSize: 12),
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
                            }).toList(),
                            ...controller.configList
                                .where((field) =>
                                    field['FieldName'] == 'Location' &&
                                    field['IsEnabled'] ==
                                        true) // 👈 Only show if enabled
                                .map((field) {
                              final bool isMandatory =
                                  field['IsMandatory'] ?? false;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SearchableMultiColumnDropdownField<
                                      LocationModel>(
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
                                    onChanged: (proj) async{
                                      controller.selectedLocation = proj;
                                      controller.selectedLocationController =
                                          proj!.location;
                                      await controller.fetchPerDiemRates();
                                      controller.fetchExchangeRatePerdiem();
                                      // loadAndAppendCashAdvanceList();
                                      field['Error'] =
                                          null; // Clear error when value selected
                                    },
                                    columnHeaders: [loc.location, loc.country],
                                    rowBuilder: (proj, searchQuery) {
                                      Widget highlight(String text) {
                                        final lowerQuery =
                                            searchQuery.toLowerCase();
                                        final lowerText = text.toLowerCase();
                                        final start =
                                            lowerText.indexOf(lowerQuery);
                                        if (start == -1 ||
                                            searchQuery.isEmpty) {
                                          return Text(text);
                                        }

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
                                                text:
                                                    text.substring(start, end),
                                                style: const TextStyle(
                                                  color: Colors.blue,
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
                                                child: Text(proj.location)),
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
                                            color: Colors.red, fontSize: 12),
                                      ),
                                    ),
                                ],
                              );
                            }).toList(),
                            const SizedBox(height: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MultiSelectMultiColumnDropdownField<
                                    CashAdvanceDropDownModel>(
                                  labelText: loc.cashAdvanceRequest,
                                  items: controller.cashAdvanceListDropDown,

                                  isMultiSelect: allowMultSelect ?? false,
                                  selectedValue: controller.singleSelectedItem,
                                  selectedValues: controller.multiSelectedItems,

                                  enabled: controller.isEditModePerdiem,
                                  // selectedValue: controller.selectedLocation,
                                  // enabled: controller.isEditModePerdiem,
                                  // controller: controller.locationController,
                                  // ignore: unnecessary_string_interpolations
                                  searchValue: (proj) =>
                                      '${proj.cashAdvanceReqId}',
                                  displayText: (proj) => proj.cashAdvanceReqId,
                                  validator: (proj) => proj == null
                                      ? loc.pleaseSelectCashAdvanceField
                                      : null,
                                  onChanged: (item) {
                                    // cashAdvanceField.value = null;
                                  },
                                  onMultiChanged: (items) {},
                                  columnHeaders: [
                                    loc.requestId,
                                    loc.requestDate
                                  ],
                                  controller: controller.cashAdvanceIds,
                                  rowBuilder: (proj, searchQuery) {
                                    Widget highlight(String text) {
                                      final lowerQuery =
                                          searchQuery.toLowerCase();
                                      final lowerText = text.toLowerCase();
                                      final start =
                                          lowerText.indexOf(lowerQuery);
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
                                              child:
                                                  Text(proj.cashAdvanceReqId)),
                                          Expanded(
                                            child: Text(
                                                controller.formattedDate(
                                                    proj.requestDate)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 14),
                                buildDateField("${loc.fromDate} *",
                                    controller.fromDateController, true,
                                    enabled: controller.isEditModePerdiem),
                                buildDateField("${loc.toDate} *",
                                    controller.toDateController, false,
                                    enabled: controller.isEditModePerdiem),
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
                                buildTextField("${loc.perDiem}*",
                                    controller.perDiemController,
                                    readOnly: true),
                                buildTextField(
                                    "${loc.totalAmount} ${controller.exchangeCurrencyCode.text}*",
                                    controller.exchangeamountInController,
                                    readOnly: true),
                                buildTextField(loc.totalAmountInInr,
                                    controller.amountInController,
                                    readOnly: true),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: TextField(
                                    controller: controller.purposeController,
                                    decoration: InputDecoration(
                                      labelText: loc.purpose,
                                      // filled: true,
                                      // fillColor: readOnly ? Colors.grey.shade200 : Colors.white,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),

                                Obx(() {
                                  return Column(
                                    children:
                                        controller.customFields.map((field) {
                                      final String label =
                                          field['FieldLabel'] ??
                                              field['FieldName'];
                                      final bool isMandatory =
                                          field['IsMandatory'] ?? false;

                                      Widget inputField;

                                      if (field['FieldType'] == 'List') {
                                        inputField =
                                            DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            labelText:
                                                '$label${isMandatory ? " *" : ""}',
                                            border: const OutlineInputBorder(),
                                          ),
                                          value: field[
                                              'SelectedValue'], // 👈 pre-fill selected value if any
                                          items: (field['Options']
                                                      as List<dynamic>?)
                                                  ?.map((option) {
                                                return DropdownMenuItem<String>(
                                                  value: option.toString(),
                                                  child:
                                                      Text(option.toString()),
                                                );
                                              }).toList() ??
                                              [],
                                          onChanged: (value) {
                                            // Save selected value in the field
                                            field['SelectedValue'] = value;
                                            controller.customFields
                                                .refresh(); // 👈 notify observers
                                          },
                                        );
                                      } else {
                                        inputField = TextField(
                                          decoration: InputDecoration(
                                            labelText:
                                                '$label${isMandatory ? " *" : ""}',
                                            border: const OutlineInputBorder(),
                                          ),
                                          onChanged: (value) {
                                            // Save entered value in the field
                                            field['EnteredValue'] = value;
                                            controller.customFields
                                                .refresh(); // 👈 notify observers
                                          },
                                        );
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
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
                                          final double lineAmount =
                                              double.tryParse(controller
                                                      .amountInController
                                                      .text) ??
                                                  0.0;

                                          if (controller.split.isEmpty &&
                                              controller.accountingDistributions
                                                  .isNotEmpty) {
                                            controller.split.assignAll(
                                              controller.accountingDistributions
                                                  .map((e) {
                                                return AccountingSplit(
                                                  paidFor: e!.dimensionValueId,
                                                  percentage:
                                                      e.allocationFactor,
                                                  amount: e.transAmount,
                                                );
                                              }).toList(),
                                            );
                                          } else if (controller.split.isEmpty) {
                                            controller.split.add(
                                                AccountingSplit(
                                                    percentage: 100.0));
                                          }

                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
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
                                                child:
                                                    AccountingDistributionWidget(
                                                  splits: controller.split,
                                                  lineAmount: lineAmount,
                                                  onChanged: (i, updatedSplit) {
                                                    if (!mounted) return;
                                                    controller.split[i] =
                                                        updatedSplit;
                                                  },
                                                  onDistributionChanged:
                                                      (newList) {
                                                    if (!mounted) return;
                                                    controller
                                                        .accountingDistributions
                                                        .clear();
                                                    controller
                                                        .accountingDistributions
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
                                if (widget.item != null)
                                  const SizedBox(height: 10),
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
                                                child:
                                                    CircularProgressIndicator());
                                          }

                                          if (snapshot.hasError) {
                                            return Center(
                                                child: Text(
                                                    'Error: ${snapshot.error}'));
                                          }

                                          final historyList = snapshot.data!;
                                          if (historyList.isEmpty) {
                                            return Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: Text(
                                                  loc.noHistoryMessage,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      color: Colors.grey),
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
                                // const SizedBox(height: 20),
                                const SizedBox(height: 20),

// Submit Button
                                if (controller.isEditModePerdiem &&
                                    widget.item == null) ...[
                                  const SizedBox(height: 20),

                                  // Submit Button
                                  Obx(() {
                                    bool isLoading =
                                        controller.buttonLoaders['submit'] ??
                                            false;
                                    return SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : () async {
                                                controller.setButtonLoading(
                                                    'submit', true);
                                                try {
                                                  if (validateForm()) {
                                                    await controller
                                                        .updatePerDiemDetails(
                                                      context,
                                                      true, // ✅ Submit
                                                      false,
                                                      null,
                                                    );
                                                  } else {
                                                    print("Validation failed");
                                                  }
                                                } finally {
                                                  controller.setButtonLoading(
                                                      'submit', false);
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 2, 21, 131), // Green
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
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
                                                loc.submit,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                      ),
                                    );
                                  }),

                                  const SizedBox(height: 12),

                                  // Save & Cancel Buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Obx(() {
                                          bool isLoading = controller
                                                  .buttonLoaders['save'] ??
                                              false;
                                          return ElevatedButton(
                                            onPressed: isLoading
                                                ? null
                                                : () async {
                                                    controller.setButtonLoading(
                                                        'save', true);
                                                    try {
                                                      if (validateForm()) {
                                                        await controller
                                                            .updatePerDiemDetails(
                                                          context,
                                                          false,
                                                          false,
                                                          null,
                                                        );
                                                      } else {
                                                        print(
                                                            "Validation failed");
                                                      }
                                                    } finally {
                                                      controller
                                                          .setButtonLoading(
                                                              'save', false);
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(255, 13,
                                                      138, 2), // Purple
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
                                                    loc.save,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                          );
                                        }),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey,
                                          ),
                                          child: Text(loc.cancel),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                // ✅ Submit Button (Created)

// ✅ Save & Cancel Buttons
// Cancel & Close Buttons (Pending approval)
                                if (controller.isEditModePerdiem &&
                                    widget.item != null &&
                                    widget.item!.approvalStatus == "Pending" &&
                                    widget.item!.stepType == null)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Obx(() {
                                          bool isLoading = controller
                                                  .buttonLoaders['cancel'] ??
                                              false;
                                          return ElevatedButton(
                                            onPressed: isLoading
                                                ? null
                                                : () async {
                                                    controller.setButtonLoading(
                                                        'cancel', true);
                                                    try {
                                                      await controller
                                                          .cancelExpense(
                                                        context,
                                                        widget.item!.recId
                                                            .toString(),
                                                      );
                                                    } finally {
                                                      controller
                                                          .setButtonLoading(
                                                              'cancel', false);
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 233, 151, 151),
                                            ),
                                            child: isLoading
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.red,
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : Text(
                                                    loc.cancel,
                                                    style: const TextStyle(
                                                        color: Colors.red),
                                                  ),
                                          );
                                        }),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              controller.chancelButton(context),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey),
                                          child: Text(
                                            loc.close,
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                if (controller.isEditModePerdiem &&
                                    widget.item != null &&
                                    widget.item!.stepType == "Review") ...[
                                  Row(
                                    children: [
                                      // 🔵 Update Button
                                      Expanded(
                                        child: Obx(() {
                                          bool isLoadingUpdate = controller
                                                  .buttonLoaders['update'] ??
                                              false;
                                          bool isAnyLoading = controller
                                              .buttonLoaders.values
                                              .any(
                                                  (loading) => loading == true);

                                          return ElevatedButton(
                                            onPressed: (isLoadingUpdate ||
                                                    isAnyLoading)
                                                ? null
                                                : () async {
                                                    controller.setButtonLoading(
                                                        'update', true);
                                                    try {
                                                      if (validateForm()) {
                                                        await controller
                                                            .perdiemApprovalReview(
                                                          context,
                                                          false, // ✅ Update
                                                          widget.item!
                                                              .workitemrecid,
                                                          widget.item!.recId
                                                              .toString(),
                                                          widget.item!.expenseId
                                                              .toString(),
                                                        );
                                                      } else {
                                                        print(
                                                            "Validation failed");
                                                      }
                                                    } finally {
                                                      controller
                                                          .setButtonLoading(
                                                              'update', false);
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 3, 20, 117),
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
                                                    loc.update,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                          );
                                        }),
                                      ),
                                      const SizedBox(width: 12),

                                      // 🟢 Update & Accept Button
                                      Expanded(
                                        child: Obx(() {
                                          bool isLoadingAccept =
                                              controller.buttonLoaders[
                                                      'updateAccept'] ??
                                                  false;
                                          bool isAnyLoading = controller
                                              .buttonLoaders.values
                                              .any(
                                                  (loading) => loading == true);

                                          return ElevatedButton(
                                            onPressed: (isLoadingAccept ||
                                                    isAnyLoading)
                                                ? null
                                                : () async {
                                                    controller.setButtonLoading(
                                                        'updateAccept', true);
                                                    try {
                                                      await controller
                                                          .perdiemApprovalReview(
                                                        context,
                                                        true, // ✅ Update & Accept
                                                        widget.item!
                                                            .workitemrecid,
                                                        widget.item!.recId
                                                            .toString(),
                                                        widget.item!.expenseId
                                                            .toString(),
                                                      );
                                                    } finally {
                                                      controller
                                                          .setButtonLoading(
                                                              'updateAccept',
                                                              false);
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 3, 20, 117),
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
                                                    loc.updateAndAccept,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                          );
                                        }),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // Reject & Close buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Obx(() {
                                          bool isLoading = controller
                                                  .buttonLoaders['reject'] ??
                                              false;
                                          return ElevatedButton(
                                            onPressed: isLoading
                                                ? null
                                                : () async {
                                                    controller.setButtonLoading(
                                                        'reject', true);
                                                    try {
                                                      showActionPopup(
                                                          context, "Reject");
                                                    } finally {
                                                      controller
                                                          .setButtonLoading(
                                                              'reject', false);
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 238, 20, 20),
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
                                                : Text(loc.reject,
                                                    // ignore: prefer_const_constructors
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                          );
                                        }),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              controller.chancelButton(context),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey),
                                          child: Text(
                                            loc.close,
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],

                                if (controller.isEditModePerdiem &&
                                    widget.item != null &&
                                    widget.item!.approvalStatus == "Created")
                                  Obx(() {
                                    bool isLoadingSubmit =
                                        controller.buttonLoaders['submit'] ??
                                            false;
                                    bool isAnyLoading = controller
                                        .buttonLoaders.values
                                        .any((loading) => loading == true);

                                    return SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: (isLoadingSubmit ||
                                                isAnyLoading)
                                            ? null
                                            : () {
                                                if (validateForm()) {
                                                  controller.setButtonLoading(
                                                      'submit', true);
                                                  controller
                                                      .updatePerDiemDetails(
                                                          context,
                                                          true,
                                                          false,
                                                          widget.item!.recId,
                                                          widget
                                                              .item!.expenseId)
                                                      .whenComplete(() =>
                                                          controller
                                                              .setButtonLoading(
                                                                  'submit',
                                                                  false));
                                                } else {
                                                  print("Validation failed");
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                          backgroundColor: const Color.fromARGB(
                                              255, 2, 19, 114),
                                        ),
                                        child: isLoadingSubmit
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
                                                loc.submit,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    );
                                  }),
                                if (controller.isEditModePerdiem &&
                                    widget.item != null &&
                                    widget.item!.approvalStatus ==
                                        "Created") ...[
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      // 📝 Save Button
                                      Expanded(
                                        child: Obx(() {
                                          bool isLoadingSave = controller
                                                  .buttonLoaders['save'] ??
                                              false;
                                          bool isAnyLoading = controller
                                              .buttonLoaders.values
                                              .any(
                                                  (loading) => loading == true);

                                          return ElevatedButton(
                                            onPressed:
                                                (isLoadingSave || isAnyLoading)
                                                    ? null
                                                    : () {
                                                        if (validateForm()) {
                                                          controller
                                                              .setButtonLoading(
                                                                  'save', true);
                                                          controller
                                                              .updatePerDiemDetails(
                                                                  context,
                                                                  false,
                                                                  false,
                                                                  widget.item!
                                                                      .recId,
                                                                  widget.item!
                                                                      .expenseId)
                                                              .whenComplete(() =>
                                                                  controller
                                                                      .setButtonLoading(
                                                                          'save',
                                                                          false));
                                                        } else {
                                                          print(
                                                              "Validation failed");
                                                        }
                                                      },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 28, 114, 2),
                                            ),
                                            child: isLoadingSave
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
                                                    loc.save,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                          );
                                        }),
                                      ),
                                      const SizedBox(width: 12),

                                      // 🚫 Cancel Button
                                      Expanded(
                                        child: Obx(() {
                                          bool isLoadingCancel = controller
                                                  .buttonLoaders['cancel'] ??
                                              false;
                                          bool isAnyLoading = controller
                                              .buttonLoaders.values
                                              .any(
                                                  (loading) => loading == true);

                                          return ElevatedButton(
                                            onPressed: (isLoadingCancel ||
                                                    isAnyLoading)
                                                ? null
                                                : () {
                                                    controller.setButtonLoading(
                                                        'cancel', true);
                                                    Future.delayed(
                                                        const Duration(
                                                            milliseconds: 500),
                                                        () {
                                                      controller.chancelButton(
                                                          context);
                                                      controller
                                                          .setButtonLoading(
                                                              'cancel', false);
                                                    });
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey,
                                            ),
                                            child: isLoadingCancel
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
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

// ✅ Resubmit Button (Rejected)
                                if (controller.isEditModePerdiem &&
                                    widget.item != null &&
                                    widget.item!.approvalStatus == "Rejected")
                                  Column(
                                    children: [
                                      Obx(() {
                                        bool isLoadingResubmit = controller
                                                .buttonLoaders['resubmit'] ??
                                            false;
                                        bool isAnyLoading = controller
                                            .buttonLoaders.values
                                            .any((loading) => loading == true);

                                        return SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: (isLoadingResubmit ||
                                                    isAnyLoading)
                                                ? null
                                                : () {
                                                    if (validateForm()) {
                                                      controller
                                                          .setButtonLoading(
                                                              'resubmit', true);
                                                      controller
                                                          .updatePerDiemDetails(
                                                            context,
                                                            true,
                                                            true,
                                                            widget.item!.recId,
                                                            widget
                                                                .item!.expenseId
                                                                .toString(),
                                                          )
                                                          .whenComplete(() =>
                                                              controller
                                                                  .setButtonLoading(
                                                                      'resubmit',
                                                                      false));
                                                    } else {
                                                      print(
                                                          "Validation failed");
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 4, 2, 114),
                                            ),
                                            child: isLoadingResubmit
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
                                                    loc.resubmit,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                          ),
                                        );
                                      }),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Obx(() {
                                              bool isLoadingUpdate =
                                                  controller.buttonLoaders[
                                                          'update'] ??
                                                      false;
                                              bool isAnyLoading = controller
                                                  .buttonLoaders.values
                                                  .any((loading) =>
                                                      loading == true);

                                              return ElevatedButton(
                                                onPressed:
                                                    (isLoadingUpdate ||
                                                            isAnyLoading)
                                                        ? null
                                                        : () {
                                                            if (validateForm()) {
                                                              controller
                                                                  .setButtonLoading(
                                                                      'update',
                                                                      true);
                                                              controller
                                                                  .updatePerDiemDetails(
                                                                    context,
                                                                    false,
                                                                    false,
                                                                    widget.item!
                                                                        .recId,
                                                                    widget.item!
                                                                        .expenseId
                                                                        .toString(),
                                                                  )
                                                                  .whenComplete(() =>
                                                                      controller.setButtonLoading(
                                                                          'update',
                                                                          false));
                                                            } else {
                                                              print(
                                                                  "Validation failed");
                                                            }
                                                          },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 20, 94, 2),
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
                                                        loc.update,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                              );
                                            }),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Obx(() {
                                              bool isAnyLoading = controller
                                                  .buttonLoaders.values
                                                  .any((loading) =>
                                                      loading == true);
                                              return ElevatedButton(
                                                onPressed: isAnyLoading
                                                    ? null
                                                    : () => controller
                                                        .chancelButton(context),
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.grey),
                                                child: Text(
                                                  loc.close,
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                if (!controller.isEditMode &&
                                    widget.item != null &&
                                    widget.item!.stepType == "Approval") ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Obx(() {
                                          bool isLoading = controller
                                                  .buttonLoaders['approve'] ??
                                              false;
                                          return ElevatedButton(
                                            onPressed: isLoading
                                                ? null
                                                : () {
                                                    controller.setButtonLoading(
                                                        'approve', true);
                                                    try {
                                                      showActionPopup(context,
                                                          "Approve"); // This is void
                                                    } finally {
                                                      controller
                                                          .setButtonLoading(
                                                              'approve', false);
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 30, 117, 3),
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
                                                    loc.approvals,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                          );
                                        }),
                                      ),
                                      const SizedBox(width: 12),

                                      // 📝 Reject Button
                                      Expanded(
                                        child: Obx(() {
                                          bool isLoading = controller
                                                  .buttonLoaders['reject'] ??
                                              false;
                                          return ElevatedButton(
                                            onPressed: isLoading
                                                ? null
                                                : () {
                                                    controller.setButtonLoading(
                                                        'reject', true);
                                                    try {
                                                      showActionPopup(
                                                          context, "Reject");
                                                    } finally {
                                                      controller
                                                          .setButtonLoading(
                                                              'reject', false);
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 238, 20, 20),
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
                                                    loc.reject,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                  // Submit, Save & Cancel Buttons (when creating)

                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      // 📝 Escalate Button
                                      Expanded(
                                        child: Obx(() {
                                          bool isLoading = controller
                                                  .buttonLoaders['escalate'] ??
                                              false;
                                          return ElevatedButton(
                                            onPressed: isLoading
                                                ? null
                                                : () {
                                                    controller.setButtonLoading(
                                                        'escalate', true);
                                                    try {
                                                      showActionPopup(context,
                                                          "Escalate"); // No await
                                                    } finally {
                                                      controller
                                                          .setButtonLoading(
                                                              'escalate',
                                                              false);
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 3, 20, 117),
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
                                                    loc.escalate,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                          );
                                        }),
                                      ),
                                      const SizedBox(width: 12),

                                      // 📝 Close Button
                                      Expanded(
                                        child: Obx(() {
                                          bool isLoading = controller
                                                  .buttonLoaders['close'] ??
                                              false;
                                          return ElevatedButton(
                                            onPressed: isLoading
                                                ? null
                                                : () {
                                                    controller.setButtonLoading(
                                                        'close', true);
                                                    Future.delayed(
                                                        const Duration(
                                                            milliseconds: 500),
                                                        () {
                                                      controller.chancelButton(
                                                          context);
                                                      controller
                                                          .setButtonLoading(
                                                              'close', false);
                                                    });
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey,
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
                                                    loc.close,
                                                    style: const TextStyle(
                                                        color: Colors.black),
                                                  ),
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ],

// Cancel Button (default)
                                if (widget.item != null &&
                                    widget.item!.stepType != "Approval" &&
                                    !controller.isEditModePerdiem)
                                  ElevatedButton(
                                    onPressed: () =>
                                        controller.chancelButton(context),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey),
                                    child: Text(loc.cancel,
                                        style: const TextStyle(
                                            color: Colors.black)),
                                  )
                              ],
                            ),
                          ])),
                    );
            })));
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          // fillColor: readOnly ? Colors.grey.shade200 : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget buildDateField(
      String label, TextEditingController controllers, bool showDatePickerOnTap,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: enabled
            ? () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateFormat('dd-MMM-yyyy')
                      .parseStrict(controllers.text.trim()),

                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(), // Disable future dates
                );
                if (picked != null) {
                  if (showDatePickerOnTap) {
                    controller.selectedDate = picked;
                  }
                  controller.selectedDate = picked;
                  controllers.text = formatDate(picked);
                 await controller.fetchPerDiemRates();
                  controller.fetchExchangeRatePerdiem();
                  if (controller.locationController.text.isNotEmpty) {
                    loadAndAppendCashAdvanceList();

                    ;
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
              // fillColor: enabled ? Color.fromARGB(69, 207, 206, 206) : Colors.grey.shade200,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
          ),
        ),
      ),
    );
  }

  DateTime _parseDateOrDefault(String dateStr, DateTime fallback) {
    try {
      return DateFormat('dd-MM-yyyy').parseStrict(dateStr.trim());
    } catch (e) {
      print("Invalid date in controllers.text: $dateStr");
      return fallback;
    }
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.deepPurple,
              ),
            ),
            // backgroundColor: Colors.white,
            // collapsedBackgroundColor: Colors.white,
            textColor: Colors.deepPurple,
            iconColor: Colors.deepPurple,
            collapsedIconColor: Colors.grey,
            childrenPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          columnHeaders: [
                            loc.userName,
                            loc.userId,
                          ],
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
                                  vertical: 12, horizontal: 16),
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
                      loc.comments,
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
                        errorText:
                            isCommentError ? 'Comment is required.' : null,
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

                            // Show full-page loading indicator
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) => const Center(
                                child: SkeletonLoaderPage(),
                              ),
                            );

                            final success = await controller.postApprovalAction(
                              context,
                              workitemrecid: [workitemrecid!],
                              decision: status,
                              comment: commentController.text,
                            );

                            // Hide the loading indicator
                            if (Navigator.of(context, rootNavigator: true)
                                .canPop()) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }

                            if (!context.mounted) return;

                            if (success) {
                              Navigator.pushNamed(
                                  context, AppRoutes.approvalDashboard);
                              controller.isApprovalEnable.value = false;
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Failed to submit action')),
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
                  Text(item.eventType,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
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
        )
      ],
    );
  }

  Widget stylishSettingsButton({
    required VoidCallback onPressed,
  }) {
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
      isScrollControlled: true, // Important for keyboard push-up
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      context: context,
      builder: (_) {
        final loc = AppLocalizations.of(context)!;
        return Padding(
          // Push content above keyboard
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
                          fontSize: 18, fontWeight: FontWeight.bold),
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
                                horizontal: 24, vertical: 12),
                          ),
                          child: Text(loc.cancel),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isSaveButtonEnabled()
                              ? () {
                                  // ✅ Only save if button is enabled
                                  for (var data in controller.allocationLines) {
                                    if (controller.setTheAllcationAmount == 0) {
                                      controller.setTheAllcationAmount =
                                          data.unitPriceTrans.toInt();
                                    }
                                    data.unitPriceTrans =
                                        controller.setTheAllcationAmount *
                                            data.parsed;
                                    data.quantity = data.parsed;
                                  }
                                  controller.paidAmount.text =
                                      controller.amountInController.text;
                                  double updatedTotal =
                                      controller.allocationLines.fold(
                                    0.0,
                                    (sum, item) => sum + item.unitPriceTrans,
                                  );

                                  controller.amountInController.text =
                                      updatedTotal.toStringAsFixed(2);
                                  controller.exchangeamountInController.text =
                                      updatedTotal.toStringAsFixed(2);
                                  print(
                                      "amountInController${controller.amountInController.text}");
                                  controller.fetchExchangeRatePerdiem();
                                  Navigator.of(context).pop();
                                }
                              : null, // 🚫 Disable button if errors
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSaveButtonEnabled()
                                ? AppColors.gradientEnd
                                : Colors.grey, // Grey out if disabled
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: Text(
                            loc.save,
                            style: TextStyle(
                              color: _isSaveButtonEnabled()
                                  ? Colors.white
                                  : Colors.black45, // Dim text
                            ),
                          ),
                        ),
                      ],
                    ),
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
    return controller.allocationLines.every(
      (data) => data.errorText == null,
    );
  }

  Widget _buildAllocationCard(AllocationLine data, {bool isPopup = false}) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: Colors.blue[50],
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
                      DateTime.fromMillisecondsSinceEpoch(data.effectiveFrom)),
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
                      DateTime.fromMillisecondsSinceEpoch(data.effectiveTo)),
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
            // color: Colors.white,
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
        Text(loc.noOfDays,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 4),
        SizedBox(
            width: 110,
            height: 40,
            child: TextFormField(
              initialValue: data.quantity.toString(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                filled: true,
                // fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (val) {
                setState(() {
                  if (val.isEmpty) {
                    data.parsed = 0;
                    data.errorText = loc.pleaseEnterNumberOfDays;
                  } else {
                    final parsed = double.tryParse(val);
                    final totalDays =
                        double.tryParse(controller.daysController.text);
                    if (parsed != null) {
                      if (parsed < 0) {
                        // Optional: prevent negative values
                        data.errorText = loc.numberOfDaysCannotBeNegative;
                      } else if (parsed > totalDays!) {
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
                  _isSaveButtonEnabled();
                });
              },
            )),
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
