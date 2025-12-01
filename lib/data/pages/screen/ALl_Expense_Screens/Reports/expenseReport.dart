// report_wizard.dart
import 'dart:convert';

import 'package:digi_xpense/core/constant/Parames/params.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/Reports/notifiarModels.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/Reports/reportsCreateForm.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../../../l10n/app_localizations.dart';
import '../../../../models.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportWizardParent extends StatefulWidget {
  const ReportWizardParent({Key? key}) : super(key: key);

  @override
  _ReportWizardParentState createState() => _ReportWizardParentState();
}

class _ReportWizardParentState extends State<ReportWizardParent> {
  int _currentStep = 0;

  final Map<String, dynamic> formData = {
    'fromDate': null,
    'toDate': null,
    'functionalEntity': null,
    'sortBy': null,
    'sortOrder': null,
  };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();



  void _nextStep() {
      final List<String> _stepTitles = [
    AppLocalizations.of(context)!.basicFiltration,
     AppLocalizations.of(context)!.advancedFiltering,
     AppLocalizations.of(context)!.applyFilters,
  ];
    print("_currentStep$_currentStep");
    if (_currentStep == _stepTitles.length - 1) {
      final reportModel = Provider.of<ReportModel>(context, listen: false);
      reportModel.callMISReportAPI(context); // Call finish function
      return;
    }
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      // Add validation for Advanced Filtering step
      final reportModel = Provider.of<ReportModel>(context, listen: false);
      if (_validateAdvancedFilters(reportModel)) {
        setState(() => _currentStep++);
      }
    } else {
      setState(() => _currentStep++);
    }
  }

  // Validation method for Advanced Filtering step
  bool _validateAdvancedFilters(ReportModel reportModel) {
    // If no filter groups, validation passes (filters are optional)
    if (reportModel.filterGroups.isEmpty) {
      return true;
    }

    // Validate each group and rule
    for (int groupIndex = 0;
        groupIndex < reportModel.filterGroups.length;
        groupIndex++) {
      final group = reportModel.filterGroups[groupIndex];

      if (group.isEmpty) {
        Fluttertoast.showToast(
          msg:
              '${AppLocalizations.of(context)!.group} ${groupIndex + 1}${AppLocalizations.of(context)!.groupIsEmpty}.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[200],
          textColor: Colors.red[800],
        );
        return false;
      }

      for (int ruleIndex = 0; ruleIndex < group.length; ruleIndex++) {
        final rule = group[ruleIndex];

        // Validate table selection
        if (rule.table.isEmpty) {
          Fluttertoast.showToast(
            msg:
                '${AppLocalizations.of(context)!.pleaseSelectColumnForRule} ${ruleIndex + 1} ${AppLocalizations.of(context)!.group} ${groupIndex + 1}.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red[200],
            textColor: Colors.red[800],
          );
          return false;
        }

        // Validate column selection
        if (rule.column.isEmpty) {
          Fluttertoast.showToast(
            msg:
                '${AppLocalizations.of(context)!.pleaseSelectColumnForRule} ${ruleIndex + 1} ${AppLocalizations.of(context)!.group} ${groupIndex + 1}.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red[200],
            textColor: Colors.red[800],
          );
          return false;
        }

        // Validate condition selection
        if (rule.condition.isEmpty) {
          Fluttertoast.showToast(
            msg:
                '${AppLocalizations.of(context)!.pleaseSelectConditionForRule} ${ruleIndex + 1} ${AppLocalizations.of(context)!.group} ${groupIndex + 1}.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red[200],
            textColor: Colors.red[800],
          );  
          return false;
        }

        // Validate value based on condition
        if (rule.condition != "Is Not Empty" &&
            rule.condition != "Is Empty" &&
            rule.condition != "In Between") {
          if (rule.value.isEmpty) {
            Fluttertoast.showToast(
              msg:
                  '${AppLocalizations.of(context)!.pleaseEnterValueForRule} ${ruleIndex + 1} ${AppLocalizations.of(context)!.group} ${groupIndex + 1}.',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red[200],
              textColor: Colors.red[800],
            );
            return false;
          }
        }

        // Validate "In Between" condition specifically
        if (rule.condition == "In Between") {
          if (rule.inBetweenValues.length < 2 ||
              rule.inBetweenValues[0].isEmpty ||
              rule.inBetweenValues[1].isEmpty) {
            Fluttertoast.showToast(
              msg:
                  '${AppLocalizations.of(context)!.pleaseEnterFromToValuesForBetween} ${ruleIndex + 1} ${AppLocalizations.of(context)!.group} ${groupIndex + 1}.',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red[200],
              textColor: Colors.red[800],
            );
            return false;
          }
        }
      }
    }

    return true;
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
      final List<String> _stepTitles = [
    AppLocalizations.of(context)!.basicFiltration,
     AppLocalizations.of(context)!.advancedFiltering,
     AppLocalizations.of(context)!.applyFilters,
  ];
    final List<Widget> screens = [
      BasicFiltrationScreen(formKey: _formKey, formData: formData),
      AdvancedFilteringScreen(formData: formData),
      ApplyFiltersScreen(formData: formData),
    ];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title:  Text(AppLocalizations.of(context)!.expenseReport),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StepTracker(steps: _stepTitles, currentStep: _currentStep),
              const SizedBox(height: 30),
              Text(
                'Step ${_currentStep + 1}: ${_stepTitles[_currentStep]}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: screens[_currentStep],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _currentStep > 0 ? _previousStep : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentStep > 0
                          ? Colors.grey[600]
                          : Colors.grey[300],
                    ),
                    child:  Text(
                      AppLocalizations.of(context)!.previous,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  if(_currentStep != _stepTitles.length - 1)
                  ElevatedButton(
                    onPressed: _nextStep,
                    child: Text(
                      _currentStep == _stepTitles.length - 1
                          ?AppLocalizations.of(context)!.applyFilters
                          : AppLocalizations.of(context)!.next,
                    ),
                  ),
                ],
              ),
               const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ Step Tracker with Connecting Line
class StepTracker extends StatelessWidget {
  final List<String> steps;
  final int currentStep;

  const StepTracker({Key? key, required this.steps, required this.currentStep})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final double stepWidth = totalWidth / steps.length;

        return SizedBox(
          height: 80,
          child: Stack(
            children: [
              if (steps.length > 1)
                Positioned(
                  top: 15,
                  left: stepWidth / 2,
                  width: totalWidth - stepWidth,
                  height: 2,
                  child: Container(color: Colors.grey[300]),
                ),
              Row(
                children: steps.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final String title = entry.value;
                  final bool isCompleted = index < currentStep;
                  final bool isActive = index == currentStep;

                  return Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted
                                ? Colors.green
                                : isActive
                                    ? Colors.blue
                                    : Colors.white,
                            border: Border.all(
                              color: isCompleted
                                  ? Colors.green
                                  : isActive
                                      ? Colors.blue
                                      : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(Icons.check,
                                    size: 16, color: Colors.white)
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: isActive
                                          ? Colors.white
                                          : (isCompleted
                                              ? Colors.white
                                              : Colors.blue),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: stepWidth - 20,
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: isActive
                                  ? Colors.blue
                                  : isCompleted
                                      ? Colors.green
                                      : Colors.grey[600],
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
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
        fillColor: !isEditable ? Colors.grey[200] : null,
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

// ✅ 1. Basic Filtration Screen
class BasicFiltrationScreen extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> formData;

  const BasicFiltrationScreen(
      {Key? key, required this.formKey, required this.formData})
      : super(key: key);

  @override
  _BasicFiltrationScreenState createState() => _BasicFiltrationScreenState();
}

class _BasicFiltrationScreenState extends State<BasicFiltrationScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    final reportModel = Provider.of<ReportModel>(context);
    reportModel.fromDateCtrl.dispose();
    reportModel.toDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      final reportModel = Provider.of<ReportModel>(context, listen: false);

      final String formatted = DateFormat('dd-MM-yyyy').format(picked);

      if (isFrom) {
        reportModel.setFromDate(picked, formatted);
      } else {
        reportModel.setToDate(picked, formatted);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportModel = Provider.of<ReportModel>(context);

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(AppLocalizations.of(context)!.basicFiltration,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextFormField(
            controller: reportModel.fromDateCtrl,
            readOnly: true,
            onTap: () => _selectDate(context, true),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.fromDate,
              suffixIcon: const Icon(Icons.calendar_today, color: Colors.blue),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            validator: (value) =>
                value!.isEmpty ? 'From Date is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: reportModel.toDateCtrl,
            readOnly: true,
            onTap: () => _selectDate(context, false),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.toDate,
              suffixIcon: const Icon(Icons.calendar_today, color: Colors.blue),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            validator: (value) => value!.isEmpty ? 'To Date is required' : null,
          ),
          const SizedBox(height: 16),
          CustomDropdownList<String>(
            labelText: AppLocalizations.of(context)!.functionalEntity,
            items: const ['Expense Requisition', 'Cash Advance Requisition'],
            displayText: (e) => e ?? '',
            selectedValue: reportModel.functionalArea.isEmpty
                ? null
                : reportModel.functionalArea,
            onChanged: (value) {
              if (value == null) return;
              reportModel.updateFunctionalAreaExpenseReport(value);
            },
            hintText: AppLocalizations.of(context)!.selectFunctionalEntity,
          ),
          const SizedBox(height: 16),
          CustomDropdownList<dynamic>(
            labelText: 'Sort By',
            items: reportModel.allDatasets,
            displayText: (e) => e ?? '',
            selectedValue: reportModel.sortBy,
            onChanged: (value) {
              if (value != null) {
                reportModel.sortBy = value;
                setState(() {});
              }
            },
            hintText: AppLocalizations.of(context)!.selectSortField,
          ),
          const SizedBox(height: 16),
          CustomDropdownList<String>(
            labelText: 'Sort Order',
            items: ['Ascending', 'Descending'],
            displayText: (e) => e ?? '',
            selectedValue: context.read<ReportModel>().sortOrder == 'asc'
                ? 'Ascending'
                : context.read<ReportModel>().sortOrder == 'desc'
                    ? 'Descending'
                    : null,
            onChanged: (value) {
              if (value != null) {
                final sortVal = value == 'Ascending' ? 'asc' : 'desc';
                context.read<ReportModel>().setSortOrder(sortVal);
              }
            },
            hintText: AppLocalizations.of(context)!.selectOrder,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ✅ Advanced Filtering Screen
class AdvancedFilteringScreen extends StatefulWidget {
  final Map<String, dynamic> formData;

  const AdvancedFilteringScreen({Key? key, required this.formData})
      : super(key: key);

  @override
  _AdvancedFilteringScreenState createState() =>
      _AdvancedFilteringScreenState();
}

class _AdvancedFilteringScreenState extends State<AdvancedFilteringScreen> {
  String? tableName;
  String? columnName;
  String? condition;
  String? value;

  @override
  void initState() {
    super.initState();
    _loadDatasets(); // Load datasets when the screen is first built
  }

  /// Master loader - calls both datasets APIs
  Future<void> _loadDatasets() async {
    final reportModel = Provider.of<ReportModel>(context, listen: false);

    try {
      final data = await reportModel.fetchDatasetsDropDown();
      reportModel.finedFunctionIDValuefunction(data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading expense datasets: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportModel = Provider.of<ReportModel>(context);
    final isEditableField = true; // make this a parameter if needed

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          AppLocalizations.of(context)!.advancedFiltration,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // Groups List
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
                      onChanged: (newOperator) => reportModel
                          .updateGroupOperator(groupIndex, newOperator),
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
                    if (isEditableField && reportModel.filterGroups.length > 1)
                      TextButton.icon(
                        icon: const Icon(Icons.delete,
                            color: Colors.red, size: 18),
                        label:  Text(AppLocalizations.of(context)!.removeGroup,
                            style: const TextStyle(color: Colors.red)),
                        onPressed: () =>
                            reportModel.removeFilterGroup(groupIndex),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Rules in Group
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: group.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, ruleIndex) {
                    return _buildFilterRuleCard(
                        group[ruleIndex], groupIndex, ruleIndex, context);
                  },
                ),

                // Add Rule button
                if (isEditableField)
                  ElevatedButton.icon(
                    onPressed: () =>
                        reportModel.addFilterRuleToGroup(groupIndex),
                    icon: const Icon(Icons.add, size: 16),
                    label:  Text(AppLocalizations.of(context)!.addNewGroup),
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

        const SizedBox(height: 20),

        // Add Group Button
        if (isEditableField)
          ElevatedButton.icon(
            onPressed: () => reportModel.addFilterGroup(),
            icon: const Icon(Icons.group_add, size: 16),
            label:  Text(AppLocalizations.of(context)!.addNewGroup),
          ),
      ],
    );
  }
}

Widget _buildFilterRuleCard(
    FilterRule rule, int groupIndex, int ruleIndex, BuildContext context) {
  final reportModel = Provider.of<ReportModel>(context, listen: false);
  List<String> conditionItems;
  if (rule.condition == 'text') {
    // Example type — replace with your real condition logic
    conditionItems = [
      'Contains',
      'Not Contains',
      'Equal To',
      'Not Equal To',
      'Starts With',
      'Ends With',
      'Is Empty',
      'Is Not Empty'
    ];
  } else {
    conditionItems = [
      'Contains',
      'Not Contains',
      'Equal To',
      'Not Equal To',
      'Starts With',
      'Ends With',
      'Is Empty',
      'Is Not Empty'
    ];
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
                          labelText: AppLocalizations.of(context)!.table,
                          items: reportModel.tableLabels,
                          value: rule.table.isEmpty ? null : rule.table,
                          onChanged: (value) {
                            if (value != null) {
                              reportModel.expenseReportselectTableForFilter(
                                  groupIndex, ruleIndex, value);
                            }
                          }),
                      const SizedBox(height: 16),
                      if (rule.availableColumns.isNotEmpty)
                        CustomDropdown(
                            labelText: AppLocalizations.of(context)!.column,
                            items: rule.availableColumns,
                            value: rule.column,
                            onChanged: (value) {
                              print('valuevalue$value');
                              reportModel.updateFilterRule(
                                  groupIndex, ruleIndex, 'column', value);
                            }),
                      if (rule.column.isNotEmpty) const SizedBox(height: 16),
                      if (rule.column.isNotEmpty)
                        CustomDropdown(
                          labelText: AppLocalizations.of(context)!.condition,
                          items: rule.conditionItems,
                          value: rule.condition.isEmpty ? null : rule.condition,
                          onChanged: (value) {
                            print('valuevalue$value');
                            if (value != null) {
                              // Save in lowercase and replace spaces with underscores
                              reportModel.updateFilterRule(
                                groupIndex,
                                ruleIndex,
                                'condition',
                                value,
                              );
                            }
                          },
                        ),
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
                              labelText: AppLocalizations.of(context)!.value,
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
                              labelText: AppLocalizations.of(context)!.from,
                              hintText: AppLocalizations.of(context)!.enterStartingValue,
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
                              labelText: AppLocalizations.of(context)!.to,
                              hintText: AppLocalizations.of(context)!.enterEndingValue,
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
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.delete,
                              color: Colors.red, size: 18),
                          label:  Text(AppLocalizations.of(context)!.removeRule,
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
            child: Text(AppLocalizations.of(context)!.and,
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
            child: Text(AppLocalizations.of(context)!.or,
                style: TextStyle(
                    color: value == 'OR' ? Colors.white : Colors.black)),
          ),
        ),
      ],
    );
  }
}

class ApplyFiltersScreen extends StatefulWidget {
  final Map<String, dynamic> formData;
  const ApplyFiltersScreen({Key? key, required this.formData})
      : super(key: key);

  @override
  State<ApplyFiltersScreen> createState() => _ApplyFiltersScreenState();
}

class _ApplyFiltersScreenState extends State<ApplyFiltersScreen> {
  bool transData = false;
  bool documentAttachments = false;
  bool accountingDistributions = false;
  bool expenseCategoryCustomFieldValues = false;
  bool transCustomfieldValues = false;
  bool headerCustomfieldValues = false;
  bool workFlowHistory = false;
  bool activityLog = false;

  /// save selected to local storage
  Future<void> _saveSelectedTables(List<String> selected) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedTables', selected);
    debugPrint("✅ Saved selected tables: $selected");
  }

  Widget _buildCheckTile({
    required bool value,
    required String title,
    String? subtitle,
    required Function(bool) onChanged,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: CheckboxListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        subtitle: subtitle != null
            ? Text(subtitle,
                style: const TextStyle(fontSize: 13, color: Colors.grey))
            : null,
        value: value,
        activeColor: Colors.blue,
        onChanged: (v) => onChanged(v ?? false),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            AppLocalizations.of(context)!.chooseTablesToViewInReport,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildCheckTile(
            value: transData,
            title:AppLocalizations.of(context)!.transData,
            onChanged: (v) => setState(() => transData = v),
          ),
          _buildCheckTile(
            value: documentAttachments,
            title: AppLocalizations.of(context)!.documentAttachments,
            onChanged: (v) => setState(() => documentAttachments = v),
          ),
          _buildCheckTile(
            value: accountingDistributions,
            title: AppLocalizations.of(context)!.accountDistribution,
            onChanged: (v) => setState(() => accountingDistributions = v),
          ),
          _buildCheckTile(
            value: expenseCategoryCustomFieldValues,
            title: AppLocalizations.of(context)!.expenseCategoryCustomFields,
            onChanged: (v) =>
                setState(() => expenseCategoryCustomFieldValues = v),
          ),
          _buildCheckTile(
            value: transCustomfieldValues,
            title: AppLocalizations.of(context)!.transCustomFieldsValues,
            onChanged: (v) => setState(() => transCustomfieldValues = v),
          ),
          _buildCheckTile(
            value: headerCustomfieldValues,
            title: AppLocalizations.of(context)!.headerCustomFieldsValues,
            onChanged: (v) => setState(() => headerCustomfieldValues = v),
          ),
          _buildCheckTile(
            value: activityLog,
            title: AppLocalizations.of(context)!.activityLog,
            onChanged: (v) => setState(() => activityLog = v),
          ),
          _buildCheckTile(
            value: workFlowHistory,
            title: AppLocalizations.of(context)!.workflowHistory,
            onChanged: (v) => setState(() => workFlowHistory = v),
          ),

          const SizedBox(height: 24),

          /// Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                backgroundColor: Colors.blue,
              ),
              icon: const Icon(Icons.check, color: Colors.white),
              label:  Text(
               AppLocalizations.of(context)!.applyFilters,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              onPressed: () async {
                final List<String> selected = [];

                /// Map UI checkboxes to API keys
                if (transData) selected.add('ExpenseTrans');
                if (documentAttachments) selected.add('DocumentAttachments');
                if (accountingDistributions) {
                  selected.add('AccountingDistributions');
                }
                if (expenseCategoryCustomFieldValues) {
                  selected.add('ExpenseCategoryCustomFieldValues');
                }
                if (transCustomfieldValues) {
                  selected.add('TransCustomfieldValues');
                }
                 if (headerCustomfieldValues) {
                  selected.add('HeaderCustomfieldValues');
                }
                 if (workFlowHistory) {
                  selected.add('WorkFlowHistory');
                }
                 if (activityLog) {
                  selected.add('ActivityLog');
                }

                await _saveSelectedTables(selected);

                if (mounted) {
                  final reportModel =
                      Provider.of<ReportModel>(context, listen: false);
                  reportModel.callMISReportAPI(context);
                }
              },
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
