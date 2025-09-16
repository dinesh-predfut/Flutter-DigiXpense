import 'dart:convert';
import 'package:digi_xpense/core/constant/Parames/params.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/Reports/notifiarModels.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../../../core/constant/url.dart';
import '../../../../../l10n/app_localizations.dart';

class ReportCreateScreen extends StatefulWidget {
  final Map<String, dynamic>? existingReport;
  final bool isEdit;
  final bool isEditable; // New flag to control editability

  const ReportCreateScreen({
    super.key,
    this.existingReport,
    required this.isEdit,
    this.isEditable = true, // Default to true for backward compatibility
  });

  @override
  _ReportCreateScreenState createState() => _ReportCreateScreenState();
}

class _ReportCreateScreenState extends State<ReportCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _initialized = false;
  bool showCheckBox = false;
  bool isEditableField = false;

  @override
  void initState() {
    super.initState();
    isEditableField = widget.existingReport == null;
    if (widget.existingReport != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeWithExistingData();
        _fetchDatasets();
      });
    }
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

  Future<void> _initializeWithExistingData() async {
    final reportModel = Provider.of<ReportModel>(context, listen: false);
    final report = widget.existingReport is List
        ? (widget.existingReport as List).first
        : widget.existingReport;
    reportModel.resrecID = report['RecId'].toString();
    reportModel.updateReportName(report['Name'] ?? '');
    reportModel.updateFunctionalArea(
        report?['FunctionalArea'] == 'ExpenseRequisition'
            ? 'Expense Requisition'
            : 'Cash Advance Requisition');

    reportModel.updateDataSet(report?['DataSet']?.toString() ?? '');
    reportModel.updateDescription(report?['Description'] ?? '');
    reportModel.updateTags(report?['AvailableFor'] ?? '');
    reportModel.updateApplicableFor(report?['ReportAvailability'] ?? 'Public');

    await _fetchDatasets();
    final metaData = report['ReportMetaData'];
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
      final response = await http.get(
        Uri.parse(
            '${Urls.baseURL}/api/v1/global/global/datasets?page=1&sort_order=asc'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken}',
        },
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
    if (!isEditableField) return; // Don't load if not editable

    final reportModel = Provider.of<ReportModel>(context, listen: false);
    try {
      final data = await reportModel.fetchDatasetsDropDown();
      reportModel.finedRecIdValuefunction(data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportModel = Provider.of<ReportModel>(context);

    final List availableColumns = () {
      if (reportModel.dataSet.isEmpty) return [];
      final recId = int.tryParse(reportModel.dataSet);
      final dataset = reportModel.allDatasets
          .firstWhereOrNull((ds) => ds['RecId'] == recId);
      if (dataset == null) return [];
      final List<Map<String, dynamic>> columns = [];
      final List chooserTables = dataset['Schema']['columnchooser'] ?? [];
      for (var table in chooserTables) {
        if (table is Map && table.containsKey('Columns')) {
          columns.addAll(List<Map<String, dynamic>>.from(table['Columns']));
        }
      }
      return columns;
    }();

    final List linesFieldsColumns = () {
      if (reportModel.dataSet.isEmpty) return [];
      final recId = int.tryParse(reportModel.dataSet);
      final dataset = reportModel.allDatasets
          .firstWhereOrNull((ds) => ds['RecId'] == recId);
      if (dataset == null) return [];
      final List<Map<String, dynamic>> columns = [];
      final List linesFields = dataset['Schema']['LinesFields'] ?? [];
      for (var field in linesFields) {
        if (field is Map &&
            field.containsKey('dataField') &&
            field.containsKey('caption')) {
          columns.add({
            'Colname': field['dataField'],
            'Label': field['caption'],
            'Type': 'string',
          });
        }
      }
      return columns;
    }();

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
            onPressed: () => Navigator.of(context).pop(false), // Stay here
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirm exit
            child: const Text(
              'Yes',
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
          title: Text(widget.isEdit
              ? isEditableField
                  ?  AppLocalizations.of(context)!.editReport
                  :  AppLocalizations.of(context)!.viewReport
              :  AppLocalizations.of(context)!.createReport),
          elevation: 1,
          // backgroundColor: Colors.white,
          actions: [
            if (widget.existingReport != null && !isEditableField)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    isEditableField = true;
                  });
                },
              ),
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
                  _buildTextField(
                    label: '${ AppLocalizations.of(context)!.reportName} *',
                    hint:  AppLocalizations.of(context)!.enterReportTitle,
                    controller: reportModel.reportName,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return  AppLocalizations.of(context)!.fieldRequired;
                      }
                      return null;
                    },
                    onChanged: (value) => reportModel.updateReportName(value),
                    isEditable: isEditableField,
                  ),
                  const SizedBox(height: 16),
                  CustomDropdown(
                    labelText: '${ AppLocalizations.of(context)!.functionalArea} *',
                    items: const [
                      'Expense Requisition',
                      'Cash Advance Requisition',
                    ],
                    value: reportModel.functionalArea,
                    onChanged: isEditableField
                        ? (value) {
                            print("value$value");
                            if (value == null) return;
                            reportModel.updateFunctionalArea(value);
                            _fetchDatasets();
                          }
                        : null,
                    isEditable: isEditableField,
                  ),
                  const SizedBox(height: 16),
                  CustomDropdownList<Map<String, dynamic>>(
                    labelText: '${ AppLocalizations.of(context)!.dataset} *',
                    items: reportModel.getFilteredDatasets(),
                    displayText: (dataset) =>
                        dataset?['Name'] ?? 'Unknown Dataset',
                    valueKey: (dataset) => dataset?['RecId']?.toString(),
                    selectedValue: () {
                      final recIdStr = reportModel.dataSet;
                      if (recIdStr.isEmpty) return null;
                      final recId = int.tryParse(recIdStr);
                      return reportModel.allDatasets
                          .firstWhereOrNull((ds) => ds['RecId'] == recId);
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
                    hintText:  AppLocalizations.of(context)!.selectDataset,
                    enabled:
                        isEditableField && reportModel.allDatasets.isNotEmpty,
                    isEditable: isEditableField,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label:  AppLocalizations.of(context)!.description,
                    controller: reportModel.description,
                    hint:  AppLocalizations.of(context)!.addShortDescription,
                    maxLines: 3,
                    onChanged: (value) => reportModel.updateDescription(value),
                    isEditable: isEditableField,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label:  AppLocalizations.of(context)!.tags,
                    hint:  AppLocalizations.of(context)!.enterTags,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return  AppLocalizations.of(context)!.fieldRequired;
                      }
                      return null;
                    },
                    onChanged: (value) => reportModel.updateTags(value),
                    controller: reportModel.tags,
                    isEditable: isEditableField,
                  ),
                  const SizedBox(height: 16),
                  CustomDropdownList<String>(
                    labelText: '${ AppLocalizations.of(context)!.applicableFor}*',
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
                    hintText:  AppLocalizations.of(context)!.selectAudience,
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
                              label:  Text( AppLocalizations.of(context)!.addGroup),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
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
                                          groupIndex, newOperator),
                                  // isEditable: isEditableField,
                                ),
                              ),
                            Row(
                              children: [
                                Text(
                                  '${ AppLocalizations.of(context)!.group} ${groupIndex + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                if (isEditableField &&
                                    reportModel.filterGroups.length > 1)
                                  TextButton.icon(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red, size: 18),
                                    label:  Text( AppLocalizations.of(context)!.removeGroup,
                                        style: TextStyle(color: Color.fromRGBO(244, 67, 54, 1))),
                                    onPressed: () => reportModel
                                        .removeFilterGroup(groupIndex),
                                    style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6)),
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
                                    group[ruleIndex], groupIndex, ruleIndex);
                              },
                            ),
                            if (isEditableField)
                              ElevatedButton.icon(
                                onPressed: () => reportModel
                                    .addFilterRuleToGroup(groupIndex),
                                icon: const Icon(Icons.add, size: 16),
                                label:  Text( AppLocalizations.of(context)!.addRuleToGroup),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              )
                          ],
                        );
                      },
                    ),
                  ],
                  if (availableColumns.isNotEmpty && showCheckBox) ...[
                    const SizedBox(height: 24),
                     Text( AppLocalizations.of(context)!.availableColumnsHeader,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    CompactColumnSelector(
                      columns: availableColumns,
                      selectedColumns: reportModel.selectedCheckbox1,
                      onToggle: isEditableField
                          ? (colname) {
                              if (reportModel.selectedCheckbox1
                                  .contains(colname)) {
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
                     Text( AppLocalizations.of(context)!.availableColumnsLines,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    CompactColumnSelector(
                      columns: linesFieldsColumns,
                      selectedColumns: reportModel.selectedCheckbox2,
                      onToggle: isEditableField
                          ? (colname) {
                              if (reportModel.selectedCheckbox2
                                  .contains(colname)) {
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
                     Text( AppLocalizations.of(context)!.noColumnsAvailable,
                        style: const TextStyle(color: Colors.grey)),
                  ],
                  if (showCheckBox) const SizedBox(height: 24),
                  if (showCheckBox && isEditableField)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          
                          if (_formKey.currentState?.validate() ?? false) {
                            if (reportModel.applicableFor == "SpecificUsers") {
                              Navigator.pushNamed(
                                  context, AppRoutes.reportsAssignUser);
                            } else {
                              await reportModel.saveReport(context);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          backgroundColor: const Color.fromARGB(255, 2, 16, 100),
                        ),
                        child:  Text(
                           AppLocalizations.of(context)!.save,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
    required ValueChanged<String> onChanged,
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

  Widget _buildFilterRuleCard(FilterRule rule, int groupIndex, int ruleIndex) {
    final reportModel = Provider.of<ReportModel>(context, listen: false);
    if (widget.existingReport != null) {
      reportModel.selectTableForFilterAppendData(
          groupIndex, ruleIndex, rule.table, rule.column);
    }
    print("rule.column&${rule.column}");
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints:
                      const BoxConstraints(minHeight: 56, maxHeight: 400),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomDropdown(
                          labelText:  AppLocalizations.of(context)!.table,
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
                                            groupIndex, ruleIndex, value);
                                  }
                                }
                              : null,
                          isEditable: isEditableField,
                        ),
                        const SizedBox(height: 16),
                        if (rule.availableColumns.isNotEmpty ||
                            widget.existingReport != null)
                          CustomDropdown(
                            labelText: 'Column',
                            items: rule.availableColumns,
                            value: rule.column,
                            onChanged: isEditableField
                                ? (value) {
                                    // if (widget.existingReport != null) {
                                    //   reportModel.selectTableForFilter(
                                    //       groupIndex, ruleIndex, rule.table);
                                    // }
                                    if (value != null) {
                                      reportModel.updateFilterRule(groupIndex,
                                          ruleIndex, 'column', value);
                                    }
                                  }
                                : null,
                            isEditable: isEditableField,
                          ),
                        if (rule.column.isNotEmpty) const SizedBox(height: 16),
                        if (rule.column.isNotEmpty)
                          CustomDropdown(
                            labelText:  AppLocalizations.of(context)!.condition,
                            items: rule.conditionItems,
                            value:
                                rule.condition.isEmpty ? null : rule.condition,
                            onChanged: isEditableField
                                ? (value) {
                                    if (value != null) {
                                      reportModel.updateFilterRule(groupIndex,
                                          ruleIndex, 'condition', value);
                                    }
                                  }
                                : null,
                            isEditable: isEditableField,
                          ),
                        if (rule.condition.isNotEmpty)
                          const SizedBox(height: 16),
                        if (rule.condition.isNotEmpty &&
                            rule.condition != "In Between")
                          const SizedBox(height: 16),
                        if (rule.condition.isNotEmpty &&
                            rule.condition != "In Between" &&
                            rule.condition != "Is Not Empty" &&
                            rule.condition != "Is Empty")
                          SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              initialValue: rule.value,
                              decoration: InputDecoration(
                                labelText:  AppLocalizations.of(context)!.value,
                                hintText: AppLocalizations.of(context)!.enterValueToMatch,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.blue.shade400),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                              ),
                              onChanged: (value) {
                                reportModel.updateFilterRule(
                                    groupIndex, ruleIndex, 'value', value);
                              },
                            ),
                          ),
                        if (rule.condition.isNotEmpty &&
                            rule.condition == "In Between") ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              initialValue: rule.inBetweenValues.isNotEmpty
                                  ? rule.inBetweenValues[0]
                                  : '',
                              decoration: InputDecoration(
                                labelText:  AppLocalizations.of(context)!.from,
                                hintText:  AppLocalizations.of(context)!.enterStartingValue,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.blue.shade400),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                              ),
                              onChanged: (val) {
                                var list = [...rule.inBetweenValues];
                                if (list.length < 2) list = ['', ''];
                                list[0] = val;
                                reportModel.updateFilterRule(groupIndex,
                                    ruleIndex, 'inBetweenValues', list);
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              initialValue: rule.inBetweenValues.length > 1
                                  ? rule.inBetweenValues[1]
                                  : '',
                              decoration: InputDecoration(
                                labelText:  AppLocalizations.of(context)!.to,
                                hintText:  AppLocalizations.of(context)!.enterEndingValue,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.blue.shade400),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                              ),
                              onChanged: (val) {
                                var list = [...rule.inBetweenValues];
                                if (list.length < 2) list = ['', ''];
                                list[1] = val;
                                reportModel.updateFilterRule(groupIndex,
                                    ruleIndex, 'inBetweenValues', list);
                              },
                            ),
                          ),
                        ],
                        // const SizedBox(height: 12),
                        if (isEditableField)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red, size: 18),
                              label:  Text( AppLocalizations.of(context)!.removeRule,
                                  style: const TextStyle(color: Colors.red)),
                              onPressed: () {
                                reportModel.removeFilterRuleFromGroup(
                                    groupIndex, ruleIndex);
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
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
        // filled: !isEditable,
        // fillColor: !isEditable ? Colors.grey[200] : null,
      ),
      readOnly: true,
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
    final Offset position =
        button.localToGlobal(Offset.zero, ancestor: overlay);
    final double y = position.dy + button.size.height;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(Offset(position.dx, y),
            Offset(position.dx + button.size.width, y + 1)),
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
    final String? selectedLabel =
        selectedValue != null ? displayText(selectedValue) : null;
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
    final Offset position =
        button.localToGlobal(Offset.zero, ancestor: overlay);
    final double y = position.dy + button.size.height;

    showMenu<T?>(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx, y, position.dx + button.size.width, y + 8),
      items: items
          .map((item) =>
              PopupMenuItem(value: item, child: Text(displayText(item))))
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

class CompactColumnSelector extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            itemCount: columns.length,
            itemBuilder: (ctx, index) {
              final col = columns[index];
              final colname = col['Colname'] as String;
              final label = col['Label'] as String;
              final isSelected = selectedColumns.contains(colname);
              return CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(label, style: const TextStyle(fontSize: 14)),
                value: isSelected,
                onChanged: isEditable && onToggle != null
                    ? (value) => onToggle!(colname)
                    : null,
                controlAffinity: ListTileControlAffinity.leading,
              );
            },
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
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
            ),
            child: Text( AppLocalizations.of(context)!.and,
                style: TextStyle(
                    color: value == 'AND' ? Colors.white : Colors.black)),
          ),
        ),
        GestureDetector(
          onTap: () => onChanged('OR'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: value == 'OR' ? Colors.blue : Colors.grey.shade200,
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
            ),
            child: Text( AppLocalizations.of(context)!.or,
                style: TextStyle(
                    color: value == 'OR' ? Colors.white : Colors.black)),
          ),
        ),
      ],
    );
  }
}
