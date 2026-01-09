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

import '../../../../core/comman/widgets/multiselectDropdown.dart';
import '../../../../l10n/app_localizations.dart';

class HubCreatePerDiemPage extends StatefulWidget {
  final bool isReadOnly;
  final PerdiemResponseModel? item;
  const HubCreatePerDiemPage({super.key, this.item, required this.isReadOnly});

  @override
  State<HubCreatePerDiemPage> createState() => _HubCreatePerDiemPageState();
}

class _HubCreatePerDiemPageState extends State<HubCreatePerDiemPage>
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
    _loadSettings();
    print("isReadOnly${widget.isReadOnly}");

    if (widget.item != null) {
      setState(() {
        controller.isEditModePerdiem = true;
      });

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
  }

  Future<void> _loadSettings() async {
    final settings = await controller.fetchGeneralSettings();
    if (settings != null) {
      setState(() {
        allowMultSelect = settings.allowMultipleCashAdvancesPerExpenseReg;
        print("allowDocAttachments$allowMultSelect");
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.fetchLocation();
      controller.fetchCustomFields();
      controller.configuration();
      await _initializeData();
    });
  }

  Future<void> loadAndAppendCashAdvanceList() async {
    controller.cashAdvanceListDropDown.clear();
    print("cashAdvanceListDropDown${controller.cashAdvanceListDropDown}");
    try {
      final newItems = await controller.fetchExpenseCashAdvanceList();
      controller.cashAdvanceListDropDown.addAll(newItems);
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
      final projectMandatory = isFieldMandatory('Project Id');
      if (controller.selectedProject == null && projectMandatory) {
        _showProjectError = true;
        isValid = false;
      } else {
        _showProjectError = false;
      }

      final locationMandatory = isFieldMandatory('Location');
      if (controller.selectedLocation == null && locationMandatory) {
        _showLocationError = true;
        isValid = false;
      } else {
        _showLocationError = false;
      }

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
          field['Error'] = null;
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
    if (widget.item == null) {
      await controller.fetchPerDiemRates();
    }
    await controller.fetchProjectName();

    if (widget.item != null) {
      print("Its Called ");
      final item = widget.item!;
      controller.isManualEntry = false;
      
      try {
        final matchedProject = controller.project.firstWhere(
          (p) => p.code == item.projectId,
        );
        controller.selectedProject = matchedProject;
        controller.projectIdController.text = matchedProject.code;
      } catch (e) {
        print("No matching project found for: ${item.projectId}");
      }

      try {
        final matchedLocation = controller.location.firstWhere(
          (l) => l.location == item.location,
        );
        controller.selectedLocationController = matchedLocation.city;
        controller.locationController.text = matchedLocation.location;
      } catch (e) {
        print("No matching location found for: ${item.location}");
      }

      controller.fromDateController.text = DateFormat('dd-MMM-yyyy')
          .format(DateTime.fromMillisecondsSinceEpoch(item.fromDate));
      controller.toDateController.text = DateFormat('dd-MMM-yyyy')
          .format(DateTime.fromMillisecondsSinceEpoch(item.toDate));  
      controller.expenseIdController.text = item.expenseId;
      controller.employeeIdController.text = item.employeeId!;
      controller.amountInController.text = item.totalAmountTrans.toString();
      controller.purposeController.text = item.description ?? '';
      historyFuture = controller.fetchExpenseHistory(item.recId);
      controller.allocationLines = item.allocationLines;
      controller.accountingDistributions = item.accountingDistributions;
      controller.fetchPerDiemRates();
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd-MMM-yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
     final loc = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: () async {
        controller.clearFormFieldsPerdiem();
        controller.isEditModePerdiem = false;
        return true;
      }, 
      child: Scaffold(
        body: Obx(() {
          return Container(
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
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            loc.perDiemDetails,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 20),
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
                                field['IsEnabled'] == true)
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
                                  setState(() {
                                    controller.selectedProject = proj;
                                    controller.selectedProject = proj;

                                    if (proj != null) {
                                      _showProjectError = false;
                                    }
                                  });
                                },
                                rowBuilder: (proj, searchQuery) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
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
                                field['IsEnabled'] == true)
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
                                onChanged: (proj) {
                                  controller.selectedLocation = proj;
                                  controller.fetchPerDiemRates();
                                  loadAndAppendCashAdvanceList();
                                  field['Error'] = null;
                                },
                                columnHeaders: [
                                  loc.location,
                                  loc.country
                                ],
                                rowBuilder: (proj, searchQuery) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
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
                              controller: controller.cashAdvanceIds,
                              items: controller.cashAdvanceListDropDown,
                              isMultiSelect: allowMultSelect ?? false,
                              selectedValue: controller.singleSelectedItem,
                              selectedValues: controller.multiSelectedItems,
                              enabled: controller.isEditModePerdiem,
                              searchValue: (proj) =>
                                  '${proj.cashAdvanceReqId}',
                              displayText: (proj) => proj.cashAdvanceReqId,
                              validator: (proj) => proj == null
                                  ? loc.pleaseSelectCashAdvanceField
                                  : null,
                              onChanged: (item) {},
                              onMultiChanged: (items) {},
                              columnHeaders: [
                                loc.requestId,
                                loc.requestDate
                              ],
                              rowBuilder: (proj, searchQuery) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Text(proj.cashAdvanceReqId)),
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
                            buildTextField(
                                "${loc.perDiem}*", controller.perDiemController,
                                readOnly: true),
                            buildTextField(
                                "${loc.totalAmount} ${controller.exchangeCurrencyCode.text}*",
                                controller.exchangeamountInController,
                                readOnly: true),
                            buildTextField(loc.totalAmountInInr,
                                controller.amountInController,
                                readOnly: true),
                            buildTextField(
                                loc.purpose, controller.purposeController,
                                readOnly: !controller.isEditModePerdiem),
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
                                      value: field['SelectedValue'],
                                      items: (field['Options']
                                                  as List<dynamic>?)
                                              ?.map((option) {
                                            return DropdownMenuItem<String>(
                                              value: option.toString(),
                                              child: Text(option.toString()),
                                            );
                                          }).toList() ??
                                          [],
                                      onChanged: (value) {
                                        field['SelectedValue'] = value;
                                        controller.customFields.refresh();
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
                                        field['EnteredValue'] = value;
                                        controller.customFields.refresh();
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
                                              percentage: e.allocationFactor,
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
                                            child: CircularProgressIndicator());
                                      }

                                     
                  if (snapshot.hasError) {
                    return Center(child: Text("No Data Available Please Skip Next"));
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
                            const SizedBox(height: 20),
                            const SizedBox(height: 20),

                    if (widget.item != null &&
                        widget.item!.stepType == "Review") ...[
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() {
                              bool isLoadingUpdate =
                                  controller.buttonLoaders['update'] ?? false;
                              bool isAnyLoading = controller
                                  .buttonLoaders.values
                                  .any((loading) => loading == true);

                              return ElevatedButton(
                                onPressed: (isLoadingUpdate || isAnyLoading)
                                    ? null
                                    : () async {
                                        controller.setButtonLoading(
                                            'update', true);
                                        try {
                                          if (validateForm()) {
                                            await controller
                                                .hubperdiemApprovalReview(
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
                                          controller.setButtonLoading(
                                              'update', false);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 3, 20, 117),
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
                                        AppLocalizations.of(context)!.update,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                              );
                            }),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Obx(() {
                              bool isLoadingAccept =
                                  controller.buttonLoaders['updateAccept'] ??
                                      false;
                              bool isAnyLoading = controller
                                  .buttonLoaders.values
                                  .any((loading) => loading == true);

                              return ElevatedButton(
                                onPressed: (isLoadingAccept || isAnyLoading)
                                    ? null
                                    : () async {
                                        controller.setButtonLoading(
                                            'updateAccept', true);
                                        try {
                                          await controller
                                              .hubperdiemApprovalReview(
                                            context,
                                            true,
                                            widget.item!.workitemrecid,
                                            widget.item!.recId.toString(),
                                            widget.item!.expenseId.toString(),
                                          );
                                        } finally {
                                          controller.setButtonLoading(
                                              'updateAccept', false);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 3, 20, 117),
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
                                    :  Text(
                                        AppLocalizations.of(context)!.updateAndAccept,
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
                              bool isLoading =
                                  controller.buttonLoaders['reject'] ?? false;
                              return ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        controller.setButtonLoading(
                                            'reject', true);
                                        try {
                                          showActionPopup(context, "Reject");
                                        } finally {
                                          controller.setButtonLoading(
                                              'reject', false);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 238, 20, 20),
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
                                    : Text(AppLocalizations.of(context)!.reject,
                                        style: const TextStyle(color: Colors.white)),
                              );
                            }),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                controller.skipCurrentItem(
                                    widget.item!.workitemrecid!, context);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey),
                              child: Text(
                                AppLocalizations.of(context)!.skip,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (widget.item != null &&
                        widget.item!.stepType == "Approval") ...[
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() {
                              bool isLoading =
                                  controller.buttonLoaders['approve'] ?? false;
                              return ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        controller.setButtonLoading(
                                            'approve', true);
                                        try {
                                          showActionPopup(context, "Approve");
                                        } finally {
                                          controller.setButtonLoading(
                                              'approve', false);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 30, 117, 3),
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
                                        AppLocalizations.of(context)!.approve,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                              );
                            }),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Obx(() {
                              bool isLoading =
                                  controller.buttonLoaders['reject'] ?? false;
                              return ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        controller.setButtonLoading(
                                            'reject', true);
                                        try {
                                          showActionPopup(context, "Reject");
                                        } finally {
                                          controller.setButtonLoading(
                                              'reject', false);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 238, 20, 20),
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
                                        AppLocalizations.of(context)!.reject,
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
                              bool isLoading =
                                  controller.buttonLoaders['escalate'] ?? false;
                              return ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        controller.setButtonLoading(
                                            'escalate', true);
                                        try {
                                          showActionPopup(context, "Escalate");
                                        } finally {
                                          controller.setButtonLoading(
                                              'escalate', false);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 3, 20, 117),
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
                                        AppLocalizations.of(context)!.escalate,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                              );
                            }),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Obx(() {
                              final isLoadingClose =
                                  controller.buttonLoaders['close_review'] ??
                                      false;
                              final isAnyLoading = controller
                                  .buttonLoaders.values
                                  .any((loading) => loading == true);

                              return ElevatedButton(
                                onPressed: (isLoadingClose || isAnyLoading)
                                    ? null
                                    : () async {
                                        controller.setButtonLoading(
                                            'close_review', true);
                                        try {
                                          controller.skipCurrentItem(
                                              widget.item!.workitemrecid!,
                                              context);
                                        } finally {
                                          controller.setButtonLoading(
                                              'close_review', false);
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
                                        AppLocalizations.of(context)!.skip,
                                      ),
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    if (!controller.isEditModePerdiem)
                      ElevatedButton(
                        onPressed: () => controller.chancelButton(context),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey),
                        child: const Text("Cancel",
                            style: TextStyle(color: Colors.black)),
                      )
                  ],
                ),
              ])
            ));
        }))
      );
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
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  if (showDatePickerOnTap) {
                    controller.selectedDate = picked;
                  }
                  controller.selectedDate = picked;
                  controllers.text = formatDate(picked);
                  if (controller.locationController.text.isNotEmpty) {
                    controller.fetchPerDiemRates();
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                              builder: (ctx) => const Center(
                                child: SkeletonLoaderPage(),
                              ),
                            );

                            final success = await controller.approvalHubpostApprovalAction(
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
                              Navigator.pushNamed(
                                  context, AppRoutes.approvalHubMain);
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
                    'Submitted on ${DateFormat('dd/MM/yyyy').format(item.createdDate)}',
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      context: context,
      builder: (_) {
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
                    const Text(
                      'Allocation Settings',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (controller.allocationLines.isNotEmpty)
                      ...controller.allocationLines.map(
                        (line) => _buildAllocationCard(line, isPopup: true),
                      ),
                    if (controller.allocationLines.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          "No allocation data found for your selected Location. Try another Location.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
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
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isSaveButtonEnabled()
                              ? () {
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

                                  double updatedTotal =
                                      controller.allocationLines.fold(
                                    0.0,
                                    (sum, item) => sum + item.unitPriceTrans,
                                  );
                                  controller.amountInController.text =
                                      updatedTotal.toStringAsFixed(2);

                                  Navigator.of(context).pop();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSaveButtonEnabled()
                                ? AppColors.gradientEnd
                                : Colors.grey,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: Text(
                            'Save',
                            style: TextStyle(
                              color: _isSaveButtonEnabled()
                                  ? Colors.white
                                  : Colors.black45,
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
                  label: 'Effective From',
                  value: _formatDate(
                      DateTime.fromMillisecondsSinceEpoch(data.effectiveFrom)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildReadonlyField(
                  label: 'Allowance Category',
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
                  label: 'Effective To',
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
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('No. of Days',
            style: TextStyle(fontSize: 12, color: Colors.black54)),
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (val) {
                setState(() {
                  if (val.isEmpty) {
                    data.parsed = 0;
                    data.errorText = "Please enter number of days";
                  } else {
                    final parsed = double.tryParse(val);

                    if (parsed != null) {
                      if (parsed < 0) {
                        data.errorText = "Number of days cannot be negative";
                      } else if (parsed > data.quantity) {
                        data.errorText =
                            "Entered days cannot exceed allocated ${data.quantity} day(s)";
                      } else {
                        data.errorText = null;
                        data.parsed = parsed;
                      }
                    } else {
                      data.errorText = "Please enter a valid number";
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