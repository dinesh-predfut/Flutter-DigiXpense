import 'dart:convert';
import 'package:diginexa/core/comman/widgets/loaderbutton.dart';
import 'package:diginexa/core/comman/widgets/permissionHelper.dart';
import 'package:diginexa/core/constant/Parames/params.dart';
import 'package:diginexa/core/constant/url.dart';
import 'package:diginexa/data/models.dart';
import 'package:diginexa/data/pages/API_Service/apiService.dart';
import 'package:diginexa/data/pages/screen/ALl_Expense_Screens/Reports/notifiarModels.dart';
import 'package:diginexa/data/pages/screen/widget/router/router.dart';
import 'package:diginexa/data/service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constant/url.dart';
import '../../../../../l10n/app_localizations.dart';

class CashAdvanceReportCreateScreen extends StatefulWidget {
  final Map<String, dynamic>? existingReport;
  final bool isEdit;
  final bool isEditable; // New flag to control editability

  const CashAdvanceReportCreateScreen({
    super.key,
    this.existingReport,
    required this.isEdit,
    this.isEditable = true, // Default to true for backward compatibility
  });

  @override
  _CashAdvanceReportCreateScreenState createState() =>
      _CashAdvanceReportCreateScreenState();
}

class _CashAdvanceReportCreateScreenState
    extends State<CashAdvanceReportCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _initialized = false;
  bool showCheckBox = false;
  bool isEditableField = false;
  bool isPreviousData = false;
  final controller = Get.find<Controller>();
  final Map<String, TextEditingController> _dateValueControllers = {};

  late final reportModel = Provider.of<ReportModel>(context, listen: false);
  @override
  void initState() {
    super.initState();

    isEditableField = widget.existingReport == null;
    isPreviousData = widget.isEditable;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.existingReport != null) {
        // ✅ Use existing report value

        // reportModel.updateFunctionalArea(_mapFA(existingFA));

        await _fetchDatasets();
        _initializeWithExistingData();
      } else {
        // ✅ Default only for new report
        reportModel.updateFunctionalArea("Cash Advance Requisition");
        await _fetchDatasets();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized && widget.existingReport == null) {
      _initialized = true;
      _initializeNewReport();
    }
  }

  void _initializeNewReport() {
    final reportModel = Provider.of<ReportModel>(context, listen: false);
    reportModel.resetForm();
  }

  final functionalAreaDisplayMap = {
    'ExpenseRequisition': 'Expense Requisition',
    'CashAdvanceRequisition': 'Cash Advance Requisition',
    'LeaveRequisition': 'Leave Requisition',
    'TimeSheetRequisition': 'TimeSheet Requisition',
  };
  Future<void> _initializeWithExistingData() async {
    final reportModel = Provider.of<ReportModel>(context, listen: false);
    final report = widget.existingReport is List
        ? (widget.existingReport as List).first
        : widget.existingReport;

    reportModel.resrecID = report['RecId'].toString();
    reportModel.updateReportName(report['Name'] ?? '');
    reportModel.updateFunctionalArea(
      functionalAreaDisplayMap[report?['FunctionalArea']] ??
          'Cash Advance Requisition',
    );

    // First, fetch datasets and populate matchedDatasets
    await _fetchDatasets();

    // Set the dataset ID and load the specific dataset
    final dataSetId = report?['DataSet']?.toString() ?? '';
    reportModel.updateDataSet(dataSetId);

    // IMPORTANT: Load datasets to populate matchedDatasets and tableLabels
    await _loadDatasets();

    // Now populate tableLabels from matchedDatasets
    // The finedRecIdValuefunction already populates tableLabels, but we need to ensure it's called
    // with the correct data. _loadDatasets calls finedRecIdValuefunction internally.

    if (!showCheckBox) {
      reportModel.addFilterRuleToGroup(0);
    }

    reportModel.updateDescription(report?['Description'] ?? '');
    reportModel.updateTags(report?['AvailableFor'] ?? '');
    reportModel.updateApplicableFor(report?['ReportAvailability'] ?? 'Public');

    final metaData = report['ReportMetaData'];

    // ✅ IMPORTANT: Populate tableColumnTypes and tableLabels before initializing filter groups
    if (metaData != null && metaData is List) {
      for (var group in metaData) {
        final rules = group['rules'] as List;
        for (var rule in rules) {
          final table = rule['selectedTable'];
          if (table != null && table.isNotEmpty) {
            // This will populate tableColumnTypes
            final columns = reportModel.getColumnsForTableLabelExpens(table);
            print("Fetched columns for table $table: ${columns.length}");

            // Also add table to tableLabels if not already there
            if (!reportModel.tableLabels.contains(table)) {
              reportModel.tableLabels.add(table);
            }
          }
        }
      }
    }

    // Now initialize filter groups with populated data
    reportModel.initializeFilterGroups(metaData);

    final columnChooser = report['ColumnChooser'];
    if (columnChooser is List) {
      reportModel.initializeColumnSelections(columnChooser);
    } else {
      reportModel.initializeColumnSelections([columnChooser]);
    }

    setState(() {
      showCheckBox = true;
    });
  }

  Future<void> _fetchDatasets() async {
    final reportModel = Provider.of<ReportModel>(context, listen: false);
    try {
      final response = await ApiService.get(
        Uri.parse(
          '${Urls.baseURL}/api/v1/global/global/datasets?page=1&sort_order=desc',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        reportModel.updateAllDatasets(data);
      } else {
        print('Failed to load datasets: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching datasets: $e');
    }
  }

  Future<void> _loadDatasets() async {
    if (!isEditableField && widget.existingReport == null) return;

    final reportModel = Provider.of<ReportModel>(context, listen: false);
    try {
      final data = await reportModel.fetchDatasetsDropDown();
      print("Fetched datasets count: ${data.length}");
      reportModel.finedRecIdValuefunction(data);
      print("Table labels after load: ${reportModel.tableLabels}");
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportModel = context.watch<ReportModel>();

    final List availableColumns = () {
      if (reportModel.dataSet.isEmpty) return [];

      final recId = int.tryParse(reportModel.dataSet);
      if (recId == null) return [];

      final dataset = reportModel.allDatasets.firstWhereOrNull(
        (ds) => ds['RecId'] == recId,
      );

      if (dataset == null) return [];

      final schema = dataset['Schema'] ?? {};
      final List chooserTables = schema['columnchooser'] ?? [];

      final List<Map<String, dynamic>> columns = [];

      for (var table in chooserTables) {
        if (table is Map && table['Columns'] is List) {
          columns.addAll(List<Map<String, dynamic>>.from(table['Columns']));
        }
      }

      return columns;
    }();

    final List linesFieldsColumns = () {
      if (reportModel.dataSet.isEmpty) return [];

      final recId = int.tryParse(reportModel.dataSet);
      if (recId == null) return [];

      final dataset = reportModel.allDatasets.firstWhereOrNull(
        (ds) => ds['RecId'] == recId,
      );

      if (dataset == null) return [];

      final schema = dataset['Schema'] ?? {};
      final List linesFields = schema['LinesFields'] ?? [];

      final List<Map<String, dynamic>> columns = [];

      for (var field in linesFields) {
        if (field is Map) {
          final dataField = field['dataField'];
          final caption = field['caption'];

          if (dataField != null && caption != null) {
            columns.add({
              'Colname': dataField.toString(),
              'Label': caption.toString(),
              'Type': 'string',
            });
          }
        }
      }

      return columns;
    }();

    return WillPopScope(
      onWillPop: () async {
        if (!isEditableField) {
          reportModel.resetForm();
          return true;
        }

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.exitForm),
            content: Text(AppLocalizations.of(context)!.exitWarning),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Stay
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(true), // Confirm exit
                child: Text(
                  AppLocalizations.of(context)!.ok,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );

        if (shouldExit ?? false) {
          reportModel.resetForm();
          Navigator.of(context).pop();
          return true; // allow back navigation
        }

        return false; // cancel back navigation
      },
      child: Scaffold(
        // backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            widget.isEdit
                ? isEditableField
                      ? '${AppLocalizations.of(context)!.edit} ${AppLocalizations.of(context)!.cashAdvance} ${AppLocalizations.of(context)!.reports}'
                      : '${AppLocalizations.of(context)!.viewCashAdvanceReturn} ${AppLocalizations.of(context)!.cashAdvance} ${AppLocalizations.of(context)!.reports}'
                : AppLocalizations.of(context)!.createReport,
          ),
          elevation: 1,
          // backgroundColor: Colors.white,
          actions: [
            if (widget.existingReport != null &&
                PermissionHelper.canUpdate("Cash Advance Reports"))
              Obx(() {
                return IconButton(
                  icon: Icon(
                    controller.isEnable.value
                        ? // View mode
                          Icons.edit_document
                        : Icons.remove_red_eye, // Edit mode
                  ),
                  onPressed: () {
                    controller.isEnable.value = !controller.isEnable.value;
                    setState(() {
                      isEditableField = !isEditableField;
                    });
                  },
                );
              }),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildTextField(
                    label: '${AppLocalizations.of(context)!.reportName} *',
                    hint: AppLocalizations.of(context)!.enterReportTitle,
                    controller: reportModel.reportName,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.fieldRequired;
                      }
                      return null;
                    },

                    isEditable: isEditableField && isPreviousData,
                  ),
                  const SizedBox(height: 16),
                  // CustomDropdown(
                  //   labelText:
                  //       '${AppLocalizations.of(context)!.functionalArea} *',
                  //   items: const [
                  //     // 'Expense Requisition',
                  //     'Cash Advance Requisition',
                  //     // 'Leave Requisition',
                  //     // 'TimeSheet Requisition',
                  //   ],
                  //   value: reportModel.functionalArea,
                  //   onChanged: isEditableField
                  //       ? (value) {
                  //           print("value$value");

                  //           reportModel.updateFunctionalArea("Cash Advance Requisition");
                  //           _fetchDatasets();
                  //         }
                  //       : null,
                  //   isEditable: isEditableField  && isPreviousData,
                  // ),
                  // const SizedBox(height: 16),
                  CustomDropdownList<Map<String, dynamic>>(
                    labelText: '${AppLocalizations.of(context)!.dataset} *',
                    items: reportModel.getFilteredDatasets(),
                    displayText: (dataset) =>
                        dataset?['Name'] ?? 'Unknown Dataset',
                    valueKey: (dataset) => dataset?['RecId']?.toString(),
                    selectedValue: () {
                      final recIdStr = reportModel.dataSet;
                      if (recIdStr.isEmpty) return null;
                      final recId = int.tryParse(recIdStr);
                      return reportModel.allDatasets.firstWhereOrNull(
                        (ds) => ds['RecId'] == recId,
                      );
                    }(),
                    onChanged: isEditableField
                        ? (selectedDataset) {
                            if (selectedDataset != null) {
                              final recId = selectedDataset['RecId'].toString();
                              reportModel.updateDataSet(recId);
                              _loadDatasets();
                              if (!showCheckBox) {
                                reportModel.addFilterRuleToGroup(0);
                              }
                            }
                            setState(() {
                              showCheckBox = true;
                            });
                          }
                        : null,
                    hintText: AppLocalizations.of(context)!.selectDataset,
                    enabled:
                        isEditableField && reportModel.allDatasets.isNotEmpty,
                    isEditable: isEditableField && isPreviousData,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: AppLocalizations.of(context)!.tags,
                    hint: AppLocalizations.of(context)!.enterTags,
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return  AppLocalizations.of(context)!.fieldRequired;
                    //   }
                    //   return null;
                    // },
                    onChanged: (value) => reportModel.updateTags(value),
                    controller: reportModel.tags,
                    isEditable: isEditableField,
                  ),

                  const SizedBox(height: 16),
                  _buildTextField(
                    label: AppLocalizations.of(context)!.description,
                    controller: reportModel.description,
                    hint: AppLocalizations.of(context)!.addShortDescription,
                    maxLines: 3,
                    onChanged: (value) => reportModel.updateDescription(value),
                    isEditable: isEditableField,
                  ),
                  const SizedBox(height: 16),

                  CustomDropdownList<String>(
                    labelText:
                        '${AppLocalizations.of(context)!.applicableFor}*',
                    items: const ['Public', 'Private', 'SpecificUsers'],
                    displayText: (value) => value ?? '',
                    valueKey: (value) => value,
                    selectedValue: reportModel.applicableFor.isEmpty
                        ? null
                        : reportModel.applicableFor,
                    onChanged: isEditableField
                        ? (value) {
                            if (value != null) {
                              reportModel.updateApplicableFor(value);
                            }
                          }
                        : null,
                    hintText: AppLocalizations.of(context)!.selectAudience,
                    enabled: isEditableField,
                    isEditable: isEditableField,
                  ),
                  const SizedBox(height: 24),
                  if (showCheckBox) ...[
                    const Text(
                      'Filter Rules',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 10),
                    if (isEditableField)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => reportModel.addFilterGroup(),
                              icon: const Icon(Icons.add, size: 16),
                              label: Text(
                                AppLocalizations.of(context)!.addGroup,
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 30),
                        ],
                      ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reportModel.filterGroups.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, groupIndex) {
                        final group = reportModel.filterGroups[groupIndex];

                        return Column(
                          children: [
                            if (isEditableField)
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: AndOrToggleButton(
                                  value: reportModel.groupOperators[groupIndex],
                                  onChanged: (newOperator) =>
                                      reportModel.updateGroupOperator(
                                        groupIndex,
                                        newOperator,
                                      ),
                                  // isEditable: isEditableField,
                                ),
                              ),
                            Row(
                              children: [
                                Text(
                                  '${AppLocalizations.of(context)!.group} ${groupIndex + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                if (isEditableField &&
                                    reportModel.filterGroups.length > 1)
                                  TextButton.icon(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    label: Text(
                                      AppLocalizations.of(context)!.removeGroup,
                                      style: TextStyle(
                                        color: Color.fromRGBO(244, 67, 54, 1),
                                      ),
                                    ),
                                    onPressed: () => reportModel
                                        .removeFilterGroup(groupIndex),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: group.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, ruleIndex) {
                                return _buildFilterRuleCard(
                                  group[ruleIndex],
                                  groupIndex,
                                  ruleIndex,
                                );
                              },
                            ),
                            if (isEditableField)
                              ElevatedButton.icon(
                                onPressed: () => reportModel
                                    .addFilterRuleToGroup(groupIndex),
                                icon: const Icon(Icons.add, size: 16),
                                label: Text(
                                  AppLocalizations.of(context)!.addRuleToGroup,
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                  if (availableColumns.isNotEmpty && showCheckBox) ...[
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context)!.availableColumnsHeader,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CompactColumnSelector(
                      columns: availableColumns,
                      selectedColumns: reportModel.selectedCheckbox1,
                      onToggle: isEditableField
                          ? (colname) {
                              if (reportModel.selectedCheckbox1.contains(
                                colname,
                              )) {
                                reportModel.removeSelectedColumn(colname);
                              } else {
                                reportModel.addSelectedColumn(colname);
                              }
                            }
                          : null,
                      isEditable: isEditableField,
                    ),
                  ],
                  if (linesFieldsColumns.isNotEmpty && showCheckBox) ...[
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context)!.availableColumnsLines,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CompactColumnSelector(
                      columns: linesFieldsColumns,
                      selectedColumns: reportModel.selectedCheckbox2,
                      onToggle: isEditableField
                          ? (colname) {
                              if (reportModel.selectedCheckbox2.contains(
                                colname,
                              )) {
                                reportModel.removeSelectedColumn2(colname);
                              } else {
                                reportModel.addSelectedColumn2(colname);
                              }
                            }
                          : null,
                      isEditable: isEditableField,
                    ),
                  ],
                  if (availableColumns.isEmpty &&
                      linesFieldsColumns.isEmpty &&
                      reportModel.dataSet.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context)!.noColumnsAvailable,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                  if (showCheckBox) const SizedBox(height: 24),
                  if (showCheckBox && isEditableField)
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() {
                        final isSaveLoading = controller.isButtonLoading(
                          'saveDraft',
                        );
                        final isAnyLoading = controller.isAnyButtonLoading();

                        return CustomLoaderButton(
                          text: AppLocalizations.of(context)!.save,
                          isLoading: isSaveLoading,
                          disabled: isAnyLoading,
                          height: 52,
                          backgroundColor: const Color(0xFF1E7503),
                          onPressed: () async {
                            controller.setButtonLoading('saveDraft', true);
                            try {
                              if (_formKey.currentState?.validate() ?? false) {
                                if (reportModel.applicableFor ==
                                    "SpecificUsers") {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.reportsAssignUser,
                                    arguments: {
                                      'page': "CashAdvanceRequisition",
                                    },
                                  );
                                } else {
                                  await reportModel.saveReport(
                                    context,
                                    "CashAdvanceRequisition",
                                  );
                                }
                              }
                            } finally {
                              controller.setButtonLoading('saveDraft', false);
                            }
                          },
                        );
                      }),
                    ),
                  if (showCheckBox && !isEditableField) _buildViewModeButtons(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewModeButtons() {
    return Column(
      children: [
        const SizedBox(height: 22),

        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.grey,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text(
            AppLocalizations.of(context)!.close,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    required bool isEditable,
  }) {
    return TextFormField(
      maxLines: maxLines,
      controller: controller,

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        // fillColor: Colors.white,
        // border: const OutlineInputBorder(),
        // enabledBorder: const OutlineInputBorder(),
        filled: !isEditable,
        // fillColor: !isEditable ? Colors.grey[200] : null,
      ),
      validator: validator,
      onChanged: onChanged,
      readOnly: !isEditable,
      enabled: isEditable,
    );
  }

  Widget buildValueInputByType({
    required FilterRule rule,
    required int groupIndex,
    required int ruleIndex,
  }) {
    final reportModel = Provider.of<ReportModel>(context, listen: false);

    // ✅ Get column type from tableColumnTypes map
    final colType =
        reportModel.tableColumnTypes[rule.table]?[rule.column]?.toLowerCase() ??
        'string';

    // ✅ Check if condition is "In Between"
    final isInBetween = rule.condition.toLowerCase() == 'in between';

    // ✅ DATE type → show date picker
    if (colType == 'date') {
      // ✅ Unique keys for controllers
      final fromControllerKey = '$groupIndex-$ruleIndex-from';
      final toControllerKey = '$groupIndex-$ruleIndex-to';

      if (!_dateValueControllers.containsKey(fromControllerKey)) {
        _dateValueControllers[fromControllerKey] = TextEditingController();
      }
      if (!_dateValueControllers.containsKey(toControllerKey)) {
        _dateValueControllers[toControllerKey] = TextEditingController();
      }

      final fromDateCtrl = _dateValueControllers[fromControllerKey]!;
      final toDateCtrl = _dateValueControllers[toControllerKey]!;

      // ✅ Convert YYYY-MM-DD to formatted display date (DD/MM/YYYY)
      String formatDisplayDate(String yyyyMmDd) {
        if (yyyyMmDd.isEmpty) return '';
        try {
          final parts = yyyyMmDd.split('-');
          if (parts.length == 3) {
            return '${parts[2]}/${parts[1]}/${parts[0]}';
          }
          return yyyyMmDd;
        } catch (_) {
          return yyyyMmDd;
        }
      }

      // ✅ Convert display date (DD/MM/YYYY) to YYYY-MM-DD for storage
      String convertToYyyyMmDd(String displayDate) {
        if (displayDate.isEmpty) return '';
        try {
          final parts = displayDate.split('/');
          if (parts.length == 3) {
            final year = int.parse(parts[2]);
            final month = int.parse(parts[1]);
            final day = int.parse(parts[0]);
            return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
          }
          return displayDate;
        } catch (_) {
          return displayDate;
        }
      }

      // ✅ Update from date display
      if (isInBetween) {
        // In Between mode - show two date pickers
        final fromValue = rule.inBetweenValues.isNotEmpty
            ? rule.inBetweenValues[0]
            : '';
        final toValue = rule.inBetweenValues.length > 1
            ? rule.inBetweenValues[1]
            : '';

        if (fromValue.isNotEmpty) {
          final formatted = formatDisplayDate(fromValue);
          if (fromDateCtrl.text != formatted) fromDateCtrl.text = formatted;
        } else {
          if (fromDateCtrl.text.isNotEmpty) fromDateCtrl.clear();
        }

        if (toValue.isNotEmpty) {
          final formatted = formatDisplayDate(toValue);
          if (toDateCtrl.text != formatted) toDateCtrl.text = formatted;
        } else {
          if (toDateCtrl.text.isNotEmpty) toDateCtrl.clear();
        }

        return Column(
          children: [
            // From Date
            GestureDetector(
              onTap: isEditableField
                  ? () async {
                      DateTime initialDate = DateTime.now();
                      if (fromValue.isNotEmpty) {
                        try {
                          final parts = fromValue.split('-');
                          if (parts.length == 3) {
                            initialDate = DateTime(
                              int.parse(parts[0]),
                              int.parse(parts[1]),
                              int.parse(parts[2]),
                            );
                          }
                        } catch (_) {}
                      }

                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        // ✅ Store as YYYY-MM-DD
                        final yyyyMmDd =
                            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                        final formatted =
                            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';

                        fromDateCtrl.text = formatted;

                        final updatedValues = [...rule.inBetweenValues];
                        if (updatedValues.isEmpty) updatedValues.add('');
                        if (updatedValues.length < 2) updatedValues.add('');
                        updatedValues[0] = yyyyMmDd;

                        reportModel.updateFilterRule(
                          groupIndex,
                          ruleIndex,
                          'inBetweenValues',
                          updatedValues,
                        );
                      }
                    }
                  : null,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: fromDateCtrl,
                  readOnly: true,
                  enabled: isEditableField,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.from,
                    hintText: 'Select from date',
                    suffixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // To Date
            GestureDetector(
              onTap: isEditableField
                  ? () async {
                      DateTime initialDate = DateTime.now();
                      if (toValue.isNotEmpty) {
                        try {
                          final parts = toValue.split('-');
                          if (parts.length == 3) {
                            initialDate = DateTime(
                              int.parse(parts[0]),
                              int.parse(parts[1]),
                              int.parse(parts[2]),
                            );
                          }
                        } catch (_) {}
                      }

                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        // ✅ Store as YYYY-MM-DD
                        final yyyyMmDd =
                            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                        final formatted =
                            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';

                        toDateCtrl.text = formatted;

                        final updatedValues = [...rule.inBetweenValues];
                        if (updatedValues.isEmpty) updatedValues.add('');
                        if (updatedValues.length < 2) updatedValues.add('');
                        updatedValues[1] = yyyyMmDd;

                        reportModel.updateFilterRule(
                          groupIndex,
                          ruleIndex,
                          'inBetweenValues',
                          updatedValues,
                        );
                      }
                    }
                  : null,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: toDateCtrl,
                  readOnly: true,
                  enabled: isEditableField,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.to,
                    hintText: 'Select to date',
                    suffixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      } else {
        // Single date picker mode
        if (rule.value.isNotEmpty) {
          final formatted = formatDisplayDate(rule.value);
          if (fromDateCtrl.text != formatted) fromDateCtrl.text = formatted;
        } else {
          if (fromDateCtrl.text.isNotEmpty) fromDateCtrl.clear();
        }

        return GestureDetector(
          onTap: isEditableField
              ? () async {
                  DateTime initialDate = DateTime.now();
                  if (rule.value.isNotEmpty) {
                    try {
                      final parts = rule.value.split('-');
                      if (parts.length == 3) {
                        initialDate = DateTime(
                          int.parse(parts[0]),
                          int.parse(parts[1]),
                          int.parse(parts[2]),
                        );
                      }
                    } catch (_) {}
                  }

                  final picked = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (picked != null) {
                    // ✅ Store as YYYY-MM-DD
                    final yyyyMmDd =
                        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                    final formatted =
                        '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';

                    fromDateCtrl.text = formatted;

                    reportModel.updateFilterRule(
                      groupIndex,
                      ruleIndex,
                      'value',
                      yyyyMmDd,
                    );
                  }
                }
              : null,
          child: AbsorbPointer(
            child: TextFormField(
              controller: fromDateCtrl,
              readOnly: true,
              enabled: isEditableField,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.value,
                hintText: 'Select date',
                suffixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
          ),
        );
      }
    }

    // ✅ NUMBER type
    if (colType == 'number') {
      if (isInBetween) {
        return Column(
          children: [
            TextFormField(
              initialValue: rule.inBetweenValues.isNotEmpty
                  ? rule.inBetweenValues[0]
                  : '',
              enabled: isEditableField,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.from,
                hintText: AppLocalizations.of(context)!.enterStartingValue,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              onChanged: (value) {
                final updatedValues = [...rule.inBetweenValues];
                if (updatedValues.isEmpty) updatedValues.add('');
                if (updatedValues.length < 2) updatedValues.add('');
                updatedValues[0] = value;
                reportModel.updateFilterRule(
                  groupIndex,
                  ruleIndex,
                  'inBetweenValues',
                  updatedValues,
                );
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: rule.inBetweenValues.length > 1
                  ? rule.inBetweenValues[1]
                  : '',
              enabled: isEditableField,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.to,
                hintText: AppLocalizations.of(context)!.enterEndingValue,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              onChanged: (value) {
                final updatedValues = [...rule.inBetweenValues];
                if (updatedValues.isEmpty) updatedValues.add('');
                if (updatedValues.length < 2) updatedValues.add('');
                updatedValues[1] = value;
                reportModel.updateFilterRule(
                  groupIndex,
                  ruleIndex,
                  'inBetweenValues',
                  updatedValues,
                );
              },
            ),
          ],
        );
      } else {
        return TextFormField(
          initialValue: rule.value,
          enabled: isEditableField,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.value,
            hintText: AppLocalizations.of(context)!.enterValueToMatch,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
          onChanged: (value) {
            reportModel.updateFilterRule(groupIndex, ruleIndex, 'value', value);
          },
        );
      }
    }

    // ✅ BOOLEAN type → dropdown True/False (In Between not applicable)
    if (colType == 'boolean') {
      return CustomDropdown(
        labelText: AppLocalizations.of(context)!.value,
        items: const ['True', 'False'],
        value: rule.value.isEmpty ? null : rule.value,
        onChanged: isEditableField
            ? (val) {
                reportModel.updateFilterRule(
                  groupIndex,
                  ruleIndex,
                  'value',
                  val,
                );
              }
            : null,
        isEditable: isEditableField,
      );
    }

    // ✅ ENUM type
    if (colType == 'enum') {
      if (isInBetween) {
        return Column(
          children: [
            TextFormField(
              initialValue: rule.inBetweenValues.isNotEmpty
                  ? rule.inBetweenValues[0]
                  : '',
              enabled: isEditableField,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.from,
                hintText: AppLocalizations.of(context)!.enterStartingValue,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              onChanged: (value) {
                final updatedValues = [...rule.inBetweenValues];
                if (updatedValues.isEmpty) updatedValues.add('');
                if (updatedValues.length < 2) updatedValues.add('');
                updatedValues[0] = value;
                reportModel.updateFilterRule(
                  groupIndex,
                  ruleIndex,
                  'inBetweenValues',
                  updatedValues,
                );
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: rule.inBetweenValues.length > 1
                  ? rule.inBetweenValues[1]
                  : '',
              enabled: isEditableField,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.to,
                hintText: AppLocalizations.of(context)!.enterEndingValue,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              onChanged: (value) {
                final updatedValues = [...rule.inBetweenValues];
                if (updatedValues.isEmpty) updatedValues.add('');
                if (updatedValues.length < 2) updatedValues.add('');
                updatedValues[1] = value;
                reportModel.updateFilterRule(
                  groupIndex,
                  ruleIndex,
                  'inBetweenValues',
                  updatedValues,
                );
              },
            ),
          ],
        );
      } else {
        return TextFormField(
          initialValue: rule.value,
          enabled: isEditableField,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.value,
            hintText: AppLocalizations.of(context)!.enterValueToMatch,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
          onChanged: (value) {
            reportModel.updateFilterRule(groupIndex, ruleIndex, 'value', value);
          },
        );
      }
    }

    // ✅ DEFAULT: STRING → plain text
    if (isInBetween) {
      return Column(
        children: [
          TextFormField(
            initialValue: rule.inBetweenValues.isNotEmpty
                ? rule.inBetweenValues[0]
                : '',
            enabled: isEditableField,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.from,
              hintText: AppLocalizations.of(context)!.enterStartingValue,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            onChanged: (value) {
              final updatedValues = [...rule.inBetweenValues];
              if (updatedValues.isEmpty) updatedValues.add('');
              if (updatedValues.length < 2) updatedValues.add('');
              updatedValues[0] = value;
              reportModel.updateFilterRule(
                groupIndex,
                ruleIndex,
                'inBetweenValues',
                updatedValues,
              );
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: rule.inBetweenValues.length > 1
                ? rule.inBetweenValues[1]
                : '',
            enabled: isEditableField,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.to,
              hintText: AppLocalizations.of(context)!.enterEndingValue,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            onChanged: (value) {
              final updatedValues = [...rule.inBetweenValues];
              if (updatedValues.isEmpty) updatedValues.add('');
              if (updatedValues.length < 2) updatedValues.add('');
              updatedValues[1] = value;
              reportModel.updateFilterRule(
                groupIndex,
                ruleIndex,
                'inBetweenValues',
                updatedValues,
              );
            },
          ),
        ],
      );
    } else {
      return TextFormField(
        initialValue: rule.value,
        enabled: isEditableField,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.value,
          hintText: AppLocalizations.of(context)!.enterValueToMatch,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
        onChanged: (value) {
          reportModel.updateFilterRule(groupIndex, ruleIndex, 'value', value);
        },
      );
    }
  }

  Widget _buildFilterRuleCard(FilterRule rule, int groupIndex, int ruleIndex) {
    final reportModel = Provider.of<ReportModel>(context, listen: false);

    // ❌ REMOVE THIS BLOCK - it's causing the build error
    // if (widget.existingReport != null) {
    //   reportModel.selectTableForFilterAppendData(
    //     groupIndex,
    //     ruleIndex,
    //     rule.table,
    //     rule.column,
    //   );
    // }

    print("rule.column&${rule.column}");
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 56,
                    maxHeight: 400,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomDropdown(
                          labelText: AppLocalizations.of(context)!.table,
                          items: reportModel.tableLabels,
                          value: rule.table.isEmpty ? null : rule.table,
                          onChanged: isEditableField
                              ? (value) {
                                  if (value != null) {
                                    reportModel.selectTableForFilter(
                                      groupIndex,
                                      ruleIndex,
                                      value,
                                    );
                                    reportModel
                                        .expenseReportselectTableForFilter(
                                          groupIndex,
                                          ruleIndex,
                                          value,
                                        );
                                  }
                                }
                              : null,
                          isEditable: isEditableField,
                        ),

                        if (rule.availableColumns.isNotEmpty ||
                            widget.existingReport != null)
                          const SizedBox(height: 16),

                        Builder(
                          builder: (context) {
                            if (rule.availableColumns.isNotEmpty ||
                                widget.existingReport != null) {
                              return CustomDropdown(
                                labelText: 'Column',
                                items: rule.availableColumns,
                                value: rule.column,
                                onChanged: isEditableField
                                    ? (value) {
                                        if (value != null) {
                                          reportModel.updateFilterRule(
                                            groupIndex,
                                            ruleIndex,
                                            'column',
                                            value,
                                          );
                                        }
                                      }
                                    : null,
                                isEditable: isEditableField,
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),

                        if (rule.column.isNotEmpty) const SizedBox(height: 16),

                        if (rule.column.isNotEmpty)
                          CustomDropdown(
                            labelText: AppLocalizations.of(context)!.condition,
                            items: rule.conditionItems,
                            value: rule.condition.isEmpty
                                ? null
                                : rule.condition,
                            onChanged: isEditableField
                                ? (value) {
                                    if (value != null) {
                                      print("Selected condition: $value");
                                      reportModel.updateFilterRule(
                                        groupIndex,
                                        ruleIndex,
                                        'condition',
                                        value,
                                      );
                                    }
                                  }
                                : null,
                            isEditable: isEditableField,
                          ),

                        if (rule.condition.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          buildValueInputByType(
                            rule: rule,
                            groupIndex: groupIndex,
                            ruleIndex: ruleIndex,
                          ),
                        ],

                        if (isEditableField)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 18,
                              ),
                              label: Text(
                                AppLocalizations.of(context)!.removeRule,
                                style: const TextStyle(color: Colors.red),
                              ),
                              onPressed: () {
                                reportModel.removeFilterRuleFromGroup(
                                  groupIndex,
                                  ruleIndex,
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class CustomDropdown extends StatelessWidget {
  final String labelText;
  final List<String> items;
  final String? value;
  final void Function(String)? onChanged;
  final bool isEditable;

  const CustomDropdown({
    Key? key,
    required this.labelText,
    required this.items,
    this.value,
    this.onChanged,
    this.isEditable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: const Icon(Icons.arrow_drop_down),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        filled: !isEditable,
        // fillColor: !isEditable ? Colors.grey[200] : null,
      ),
      readOnly: !isEditable,
      enabled: isEditable,
      onTap: isEditable
          ? () {
              if (items.isEmpty) return;
              FocusScope.of(context).unfocus();
              _showPopupMenu(context);
            }
          : null,
      controller: TextEditingController(text: value ?? ''),
    );
  }

  void _showPopupMenu(BuildContext context) {
    if (items.isEmpty) return;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );
    final double y = position.dy + button.size.height;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          Offset(position.dx, y),
          Offset(position.dx + button.size.width, y + 1),
        ),
        Offset.zero & overlay.size,
      ),
      items: items
          .map((item) => PopupMenuItem(value: item, child: Text(item)))
          .toList(),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // side: BorderSide(color: Colors.grey.shade300),
      ),
      constraints: BoxConstraints(maxHeight: 200, minWidth: button.size.width),
    ).then((selectedValue) {
      if (selectedValue != null && onChanged != null) onChanged!(selectedValue);
    });
  }
}

class CustomDropdownList<T> extends StatelessWidget {
  final String labelText;
  final List<T> items;
  final String Function(T?) displayText;
  final String? Function(T?)? valueKey;
  final T? selectedValue;
  final void Function(T?)? onChanged;
  final String? hintText;
  final bool enabled;
  final bool isEditable;

  const CustomDropdownList({
    Key? key,
    required this.labelText,
    required this.items,
    required this.displayText,
    this.valueKey,
    this.selectedValue,
    this.onChanged,
    this.hintText,
    this.enabled = true,
    this.isEditable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? selectedLabel = selectedValue != null
        ? displayText(selectedValue)
        : null;
    final String placeholder = hintText ?? 'Select ${labelText.toLowerCase()}';

    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: const Icon(Icons.arrow_drop_down),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        hintText: placeholder,
        filled: !isEditable,
        // fillColor: !isEditable ? Colors.grey[200] : null,
      ),
      readOnly: true,
      enabled: enabled && isEditable,
      onTap: (enabled && isEditable)
          ? () {
              if (!enabled) return;
              FocusScope.of(context).unfocus();
              _showPopupMenu(context);
            }
          : null,
      controller: TextEditingController(text: selectedLabel ?? ''),
    );
  }

  void _showPopupMenu(BuildContext context) {
    if (items.isEmpty) return;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );
    final double y = position.dy + button.size.height;

    showMenu<T?>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        y,
        position.dx + button.size.width,
        y + 8,
      ),
      items: items
          .map(
            (item) =>
                PopupMenuItem(value: item, child: Text(displayText(item))),
          )
          .toList(),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      constraints: BoxConstraints(maxHeight: 200, minWidth: button.size.width),
    ).then((selected) {
      if (selected != null && onChanged != null) onChanged!(selected);
    });
  }
}

class CompactColumnSelector extends StatefulWidget {
  final List columns;
  final List<String> selectedColumns;
  final ValueChanged<String>? onToggle;
  final bool isEditable;

  const CompactColumnSelector({
    Key? key,
    required this.columns,
    required this.selectedColumns,
    this.onToggle,
    this.isEditable = true,
  }) : super(key: key);

  @override
  State<CompactColumnSelector> createState() => _CompactColumnSelectorState();
}

class _CompactColumnSelectorState extends State<CompactColumnSelector> {
  final ScrollController _scrollController = ScrollController();
  bool _isAtBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final atBottom =
          _scrollController.offset >=
          _scrollController.position.maxScrollExtent - 8;

      if (atBottom != _isAtBottom) {
        setState(() => _isAtBottom = atBottom);
      }
    });
  }

  void _scrollToggle() {
    final target = _isAtBottom
        ? 0.0
        : _scrollController.position.maxScrollExtent;

    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        /// ✅ Card Background
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                blurRadius: 12,
                spreadRadius: 1,
                offset: Offset(0, 4),
                color: Colors.black12,
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),

              /// ✅ Scrollable List
              SizedBox(
                height: 200,
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: widget.columns.length,
                    itemBuilder: (ctx, index) {
                      final col = widget.columns[index];
                      final colname = col['Colname'] as String;
                      final label = col['Label'] as String;
                      final isSelected = widget.selectedColumns.contains(
                        colname,
                      );

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withOpacity(0.08)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CheckboxListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 6,
                          ),
                          title: Text(
                            label,
                            style: const TextStyle(fontSize: 14),
                          ),
                          value: isSelected,
                          onChanged:
                              widget.isEditable && widget.onToggle != null
                              ? (_) => widget.onToggle!(colname)
                              : null,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        /// ✅ Scroll Toggle Button (Right Bottom)
        Positioned(
          right: 6,
          bottom: 6,
          child: Material(
            elevation: 4,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _scrollToggle,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary,
                ),
                child: Icon(
                  _isAtBottom ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AndOrToggleButton extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const AndOrToggleButton({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => onChanged('AND'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: value == 'AND' ? Colors.green : Colors.grey.shade200,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.and,
              style: TextStyle(
                color: value == 'AND' ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => onChanged('OR'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: value == 'OR' ? Colors.blue : Colors.grey.shade200,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(20),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.or,
              style: TextStyle(
                color: value == 'OR' ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
