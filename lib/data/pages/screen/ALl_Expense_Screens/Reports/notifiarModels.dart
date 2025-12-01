import 'dart:convert';

import 'package:digi_xpense/core/constant/url.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/constant/Parames/params.dart';

class ReportModel with ChangeNotifier {
  final TextEditingController reportName = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController tags = TextEditingController();
  late TextEditingController fromDateCtrl = TextEditingController();
  late TextEditingController toDateCtrl = TextEditingController();
  // String reportName = '';
  String comparefunctionalAreaWithRes = '';
  String _functionalArea = '';
  String sortBy = '';
  String recID = '';
  String resrecID = '';
  String sortOrder = '';
  int? fromDateMillis;
  int? toDateMillis;
  // String description.text = '';
  bool showCheckBox = false;
  String _applicableFor = '';
  String globalOperator = 'AND'; // Global operator between groups
  List<String> groupOperators = ['AND'];
  List<FilterRule> _filterRules = [];
  List<String> _selectedFields = [];
  List<dynamic> matchedDatasets = [];
  List<Users> finelselectedUsers = [];
  List<ColumnChooser> availableColumns = [];
  List<String> selectedColumns = [];
  final List<ColumnChooserCheckbox> availableColumnLabels = [];
  Map<String, Map<String, String>> tableColumnTypes = {};
  List<String> tableLabels = [];
  List<String> selectedCheckbox1 = [];
  List<String> selectedCheckbox2 = [];
  List<String> get selectedCheckBox => List.unmodifiable(selectedCheckbox1);
  List<String> get selectedCheckBox2 => List.unmodifiable(selectedCheckbox2);

  String get reportNames => reportName.text;
  String get functionalArea => _functionalArea;
  String get dataSet => recID;
  String get descriptionss => description.text;
  String get applicableFor => _applicableFor;
  List<FilterRule> get filterRules => _filterRules;
  List<String> get selectedFields => _selectedFields;
  List<dynamic> allDatasets = [];
  List<dynamic> finedRecIdValue = [];

  get handleSelectionChanged => null;
  List<List<FilterRule>> filterGroups = [[]]; // Initialize with one empty group

  void addFilterGroup() {
    filterGroups.add([]);
    groupOperators.add('AND'); // Default operator for new group
    notifyListeners();
  }

  void addFilterRuleToGroup(int groupIndex) {
    if (groupIndex < filterGroups.length) {
      filterGroups[groupIndex].add(
        FilterRule(table: '', column: '', condition: '', value: ''),
      );
      notifyListeners();
    }
  }

  void resetForm() {
    resrecID = '';
    reportName.text = '';
    _functionalArea = '';
    recID = '';
    description.text = '';
    tags.text = '';
    _applicableFor = '';
    filterGroups = [[]]; // Reset with one empty group
    groupOperators = ['AND']; // Reset with default operator
    selectedCheckbox1 = [];
    selectedCheckbox2 = [];
    showCheckBox = false;
    notifyListeners();
  }

  void removeFilterRuleFromGroup(int groupIndex, int ruleIndex) {
    if (groupIndex < filterGroups.length &&
        ruleIndex < filterGroups[groupIndex].length) {
      filterGroups[groupIndex].removeAt(ruleIndex);
      notifyListeners();
    }
  }

  void removeFilterGroup(int groupIndex) {
    if (groupIndex >= 0 && groupIndex < filterGroups.length) {
      filterGroups.removeAt(groupIndex);
      if (groupIndex < groupOperators.length) {
        groupOperators.removeAt(groupIndex);
      }
      notifyListeners();
    }
  }

  void updateReportName(String value) {
    print("value$value");
    reportName.text = value;
    notifyListeners();
  }

  void updateFunctionalArea(String value) {
    _functionalArea = value;

    final filtered = allDatasets.where((ds) {
      if (ds is! Map<String, dynamic>) return false; // skip invalid entries
      final dsFA = ds['FunctionalArea']?.toString();
      if (value == 'Expense Requisition') {
        return dsFA == 'ExpenseRequisition';
      } else if (value == 'Cash Advance Requisition') {
        return dsFA == 'CashAdvanceRequisition';
      }
      return false;
    }).toList();

    updateAllDatasets(filtered);
    notifyListeners();
  }

  void updateFunctionalAreaExpenseReport(String value) {
    allDatasets = [];
    sortBy = "";
    _functionalArea = value;
    fetchDatasetsExpense(value);
    // final filtered = allDatasets.where((ds) {
    //   final dsFA = ds['FunctionalArea'] as String?;
    //   if (value == 'Expense Requisition') {
    //     return dsFA == 'ExpenseRequisition';
    //   } else if (value == 'Cash Advance Requisition') {
    //     return dsFA == 'CashAdvanceRequisition';
    //   }
    //   return false;
    // }).toList();
    // updateAllDatasets(filtered);
    notifyListeners();
  }

  void updateAllDatasets(List<dynamic> datasets) {
    allDatasets = datasets;

    notifyListeners();
  }

  void finedRecIdValuefunction(List<dynamic> datasets) {
    finedRecIdValue = datasets;
    // print("matchedDatasets$finedRecIdValue");
    matchedDatasets = finedRecIdValue.where((item) {
      if (item is Map<String, dynamic> && item.containsKey('RecId')) {
        var recId = item['RecId'];
        var searchRecId = int.tryParse(recID ?? '') ?? recID;
        return (recId is int && recId == searchRecId) ||
            (recId is String && recId == recID);
      }

      return false;
    }).toList();
    tableLabels = [];
    for (var dataset in matchedDatasets) {
      if (dataset is Map<String, dynamic> &&
          dataset.containsKey('Schema') &&
          dataset['Schema'] is Map<String, dynamic>) {
        var schema = dataset['Schema'];
        if (schema.containsKey('tables') && schema['tables'] is List) {
          for (var table in schema['tables']) {
            if (table is Map<String, dynamic> &&
                table.containsKey('TableName')) {
              tableLabels.add(table['TableName'] as String);
            }
          }
        }
      }
    }

    // Now tableLabels contains all TableLabel strings
    print("tableLabels$tableLabels");
    // Output: ['Expense Header', 'Expense Trans', 'Accounting Distribution', 'Employees', ...]
    print("matchedDatasets$matchedDatasets");
    notifyListeners();
  }

  void finedFunctionIDValuefunction(List<dynamic> datasets) {
    finedRecIdValue = datasets;

    // Compare FunctionalArea instead of RecId
    matchedDatasets = finedRecIdValue.where((item) {
      if (item is Map<String, dynamic> && item.containsKey('FunctionalArea')) {
        var functionalArea = item['FunctionalArea'];
        return functionalArea == comparefunctionalAreaWithRes;
      }
      return false;
    }).toList();

    tableLabels = [];
    for (var dataset in matchedDatasets) {
      if (dataset is Map<String, dynamic> &&
          dataset.containsKey('Schema') &&
          dataset['Schema'] is Map<String, dynamic>) {
        var schema = dataset['Schema'];
        if (schema.containsKey('tables') && schema['tables'] is List) {
          for (var table in schema['tables']) {
            if (table is Map<String, dynamic> &&
                table.containsKey('TableName')) {
              tableLabels.add(table['TableName'] as String);
            }
          }
        }
      }
    }

    // Now tableLabels contains all TableLabel strings
    print("tableLabelssss$tableLabels");
    // Output: ['Expense Header', 'Expense Trans', 'Accounting Distribution', 'Employees', ...]
    print("matchedDatasets$matchedDatasets");
    notifyListeners();
  }

  void handleSelectionChangedss(List<String> selectedColumns) {
    selectedColumns = selectedColumns;
  }

  void updateDataSet(String value) {
    recID = value;
    print("tableLabels$value");
    // dataSet = value;
    notifyListeners();
  }

  void updateDescription(String value) {
    description.text = value;
    notifyListeners();
  }

  void updateTags(String value) {
    tags.text = value;
    notifyListeners();
  }

  void updateApplicableFor(String value) {
    _applicableFor = value;
    notifyListeners();
  }

  void addFilterRule() {
    _filterRules.add(
      FilterRule(table: '', column: '', condition: '', value: ''),
    );
    notifyListeners();
  }

  void removeFilterRule(int index) {
    _filterRules.removeAt(index);
    notifyListeners();
  }

  Map<String, List<String>> conditionsByType = {
    'string': [
      'Contains',
      'Not Contains',
      'Equal To',
      'Not Equal To',
      'Starts With',
      'Ends With',
      'Is Empty',
      'Is Not Empty',
    ],
    'number': [
      'Equals To',
      'Not Equals To',
      'Greater than',
      'Less than',
      'Greater Than Equal To',
      'Less Than Equal To',
      'In Between',
    ],
    'date': [
      'Equals To',
      'Not Equals To',
      'Greater than',
      'Less than',
      'Greater Than Equal To',
      'Less Than Equal To',
      'In Between',
    ],
  };

  void updateFilterRule(
    int groupIndex,
    int ruleIndex,
    String field,
    dynamic value,
  ) {
    if (groupIndex < 0 || groupIndex >= filterGroups.length) return;

    final group = filterGroups[groupIndex];
    if (ruleIndex < 0 || ruleIndex >= group.length) return;

    final rule = group[ruleIndex];

    switch (field) {
      case 'table':
        rule.table = value;
        rule.column = '';
        rule.condition = '';
        rule.value = '';
        rule.inBetweenValues = [];
        rule.availableColumns = _getColumnsForTable(value);
        rule.conditionItems = [];
        break;

      case 'column':
        rule.column = value;
        rule.condition = '';
        rule.value = '';
        rule.inBetweenValues = [];
        String? colType = tableColumnTypes[rule.table]?[value];
        print("colType$tableColumnTypes");
        if (colType != null && conditionsByType.containsKey(colType)) {
          rule.conditionItems = conditionsByType[colType]!;
        } else {
          rule.conditionItems = [];
        }
        break;

      case 'condition':
      rule.condition = value;

      // FIX: Check for correct "In Between" condition
      if (value.toString().trim().toLowerCase() != 'in between'.toLowerCase()) {
        rule.inBetweenValues = [];
      }
      break;

      case 'value':
        rule.value = value;
        break;

      case 'inBetweenValues':
        if (value is List<String>) {
          rule.inBetweenValues = value;
        }
        break;
    }

    notifyListeners();
  }

  void initializeFilterGroups(List<dynamic> metaData) {
    filterGroups.clear();
    groupOperators.clear();

    for (var group in metaData) {
      final rules = group['rules'] as List;
      final operator = group['matchType'] as String;

      final filterRules = rules
          .map(
            (rule) => FilterRule(
              table: rule['selectedTable'],
              column: rule['selectedField'],
              condition: rule['selectedCondition'],
              value: rule['singleValue'],
            ),
          )
          .toList();

      filterGroups.add(filterRules);
      groupOperators.add(operator);
    }

    if (filterGroups.isEmpty) {
      filterGroups.add([]);
      groupOperators.add('AND');
    }
    print(
      "filterGroups: ${jsonEncode(filterGroups.map((group) => group.map((rule) => rule.toJson()).toList()).toList())}",
    );

    notifyListeners();
  }

  void initializeColumnSelections(dynamic columnChooserData) {
    print('\n--- INITIALIZING COLUMN SELECTIONS ---');
    print('Input data type: ${columnChooserData.runtimeType}');
    print('Input data value: $columnChooserData');

    selectedCheckbox1.clear();
    selectedCheckbox2.clear();

    try {
      if (columnChooserData is List) {
        print('\nProcessing as LIST format');
        for (var item in columnChooserData) {
          print('List item type: ${item.runtimeType}');
          print('List item value: $item');

          if (item is Map) {
            if (item.containsKey('header')) {
              final header = item['header'] as Map<String, dynamic>? ?? {};
              print('\nHeader columns found: $header');

              header.forEach((key, value) {
                if (value == true) {
                  print('Adding to header selection: $key');
                  selectedCheckbox1.add(key);
                }
              });
            }

            if (item.containsKey('lines')) {
              final lines = item['lines'] as Map<String, dynamic>? ?? {};
              print('\nLines columns found: $lines');

              lines.forEach((key, value) {
                if (value == true) {
                  print('Adding to lines selection: $key');
                  selectedCheckbox2.add(key);
                }
              });
            }
          }
        }
      } else if (columnChooserData is Map) {
        print('\nProcessing as MAP format');
        final header =
            columnChooserData['header'] as Map<String, dynamic>? ?? {};
        final lines = columnChooserData['lines'] as Map<String, dynamic>? ?? {};

        print('Header columns: $header');
        print('Lines columns: $lines');

        header.forEach((key, value) {
          if (value == true) {
            print('Adding to header selection: $key');
            selectedCheckbox1.add(key);
          }
        });

        lines.forEach((key, value) {
          if (value == true) {
            print('Adding to lines selection: $key');
            selectedCheckbox2.add(key);
          }
        });
      }

      print('\n--- FINAL SELECTIONS ---');
      print('Header selections: $selectedCheckbox1');
      print('Lines selections: $selectedCheckbox2');
    } catch (e) {
      print('\n--- ERROR IN INITIALIZATION ---');
      print(e);
    }

    notifyListeners();
  }

  List<String> _getColumnsForTable(String table) {
    // Implement your logic to get columns for the selected table
    // This might involve looking up from your dataset structure
    if (table.isEmpty) return [];

    // Example implementation - adjust based on your data structure
    if (table == 'Expense') {
      return ['Amount', 'Date', 'Category'];
    } else if (table == 'User') {
      return ['Name', 'Department', 'Role'];
    }

    return [];
  }

  void addSelectedField(String field) {
    _selectedFields.add(field);
    notifyListeners();
  }

  void removeSelectedField(String field) {
    _selectedFields.remove(field);
    notifyListeners();
  }

  List<Map<String, dynamic>> getFilteredDatasets() {
    if (functionalArea == 'Expense Requisition') {
      return allDatasets
          .where((ds) => ds['FunctionalArea'] == 'ExpenseRequisition')
          .cast<Map<String, dynamic>>()
          .toList();
    } else if (functionalArea == 'Cash Advance Requisition') {
      return allDatasets
          .where((ds) => ds['FunctionalArea'] == 'CashAdvanceRequisition')
          .cast<Map<String, dynamic>>()
          .toList();
    }
    return [];
  }

  void updateGlobalOperator(String newOperator) {
    globalOperator = newOperator;
    notifyListeners();
  }

  // Update operator for a specific group
  void updateGroupOperator(int groupIndex, String newOperator) {
    if (groupIndex >= 0 && groupIndex < groupOperators.length) {
      groupOperators[groupIndex] = newOperator;
      notifyListeners();
    }
  }

  String? get selectedDatasetName {
    final selected = allDatasets.firstWhere(
      (d) => d['RecId'].toString() == recID,
      orElse: () => null,
    );
    return selected?['RecId'];
  }

  Future<List<dynamic>> fetchDatasetsDropDown() async {
    final url = Uri.parse(
      'https://api.digixpense.com/api/v1/global/global/datasets?page=1&sort_order=asc',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization':
              'Bearer ${Params.userToken}', // Required for authentication
          'Content-Type': 'application/json',
        },
      );

      // Check if the response is successful (status 200-299)
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          return data;
        } else {
          throw Exception('Expected a list of datasets');
        }
      } else {
        throw Exception(
          'Failed to load datasets: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error fetching datasets: $e');
      rethrow;
    }
  }

  void selectTableForFilter(int groupIndex, int ruleIndex, String tableLabel) {
    // Validate indices
    if (groupIndex < 0 || groupIndex >= filterGroups.length) return;
    if (ruleIndex < 0 || ruleIndex >= filterGroups[groupIndex].length) return;

    final rule = filterGroups[groupIndex][ruleIndex];

    // Update the table (this will reset column)
    updateFilterRule(groupIndex, ruleIndex, 'table', tableLabel);

    // Get column definitions
    final columns = getColumnsForTableLabel(tableLabel);
    print("columnsss$columns");

    // Extract only the 'colname' strings
    final labels = columns
        .map((col) => col['colname'] as String)
        .where((label) => label != null && label.isNotEmpty)
        .toList();

    // Update availableColumns
    rule.availableColumns = labels;

    // ✅ Reset column if it's not in the new availableColumns
    if (!labels.contains(rule.column)) {
      rule.column = '';
    }

    print(
      "Column Labels for group $groupIndex, rule $ruleIndex (Table: '$tableLabel'): $labels",
    );

    notifyListeners();
  }

  void expenseReportselectTableForFilter(
    int groupIndex,
    int ruleIndex,
    String tableName,
  ) {
    if (groupIndex < 0 || groupIndex >= filterGroups.length) return;
    if (ruleIndex < 0 || ruleIndex >= filterGroups[groupIndex].length) return;

    final rule = filterGroups[groupIndex][ruleIndex];

    // Update selected table
    updateFilterRule(groupIndex, ruleIndex, 'table', tableName);

    // Fetch columns by TableName
    final columns = getColumnsForTableLabelExpens(tableName);
    print("Fetched columns: $columns");

    // Extract 'colname' only
    final colNames = columns
        .map((col) => col['colname'] ?? '')
        .where((c) => c.isNotEmpty)
        .toList();

    rule.availableColumns = colNames;

    if (!colNames.contains(rule.column)) {
      rule.column = '';
    }

    print("Available Colnames for $tableName: $colNames");
    notifyListeners();
  }

  void selectTableForFilterAppendData(
    int groupIndex,
    int ruleIndex,
    String tableLabel,
    String column,
  ) {
    // Validate indices
    if (groupIndex < 0 || groupIndex >= filterGroups.length) return;
    if (ruleIndex < 0 || ruleIndex >= filterGroups[groupIndex].length) return;

    final rule = filterGroups[groupIndex][ruleIndex];

    // Update the table (this will reset column)
    updateFilterRule(groupIndex, ruleIndex, 'table', tableLabel);

    // Get column definitions
    final columns = getColumnsForTableLabel(tableLabel);
    print("columns$columns");

    // Extract only the 'colname' strings
    final labels = columns
        .map((col) => col['colname'] as String)
        .where((label) => label != null && label.isNotEmpty)
        .toList();

    // Update availableColumns
    rule.availableColumns = labels;
    rule.column = column;
    // ✅ Reset column if it's not in the new availableColumns
    if (!labels.contains(rule.column)) {}

    print(
      "Column Labels for group $groupIndex, rule $ruleIndex (Table: '$tableLabel'): $labels",
    );

    notifyListeners();
  }

  List<Map<String, String>> getColumnsForTableLabel(String tableLabel) {
    // Trim and normalize input
    final normalizedLabel = tableLabel.trim();

    for (var dataset in allDatasets) {
      if (dataset is! Map<String, dynamic> || !dataset.containsKey('Schema'))
        continue;

      final schema = dataset['Schema'];
      if (schema is! Map<String, dynamic> || !schema.containsKey('tables'))
        continue;

      final tables = schema['tables'];
      if (tables is! List) continue;

      for (var table in tables) {
        if (table is! Map<String, dynamic>) continue;

        final tableLabelFromData = table['TableName'];
        if (tableLabelFromData is! String) continue;

        // Trim and compare safely
        if (tableLabelFromData.trim() == normalizedLabel) {
          if (!table.containsKey('Columns')) return [];

          final columns = table['Columns'];
          if (columns is! List) return [];

          return columns
              .where(
                (col) =>
                    col is Map<String, dynamic> &&
                    col.containsKey('Label') &&
                    col.containsKey('Colname'),
              )
              .map(
                (col) => {
                  'colname': col['Colname'].toString(),
                  'label': col['Label'].toString(),
                },
              )
              .toList()
              .cast<Map<String, String>>();
        }
      }
    }

    // Debug: Log available TableLabels if not found
    final available = <String>[];
    for (var dataset in allDatasets) {
      final schema = dataset['Schema'];
      if (schema != null && schema['tables'] is List) {
        for (var table in schema['tables']) {
          if (table is Map && table.containsKey('TableName')) {
            available.add(table['TableName']);
          }
        }
      }
    }
    print(
      "🔍 TableLabel '$tableLabel' not found. Available TableLabels: $available",
    );

    return [];
  }

  List<Map<String, String>> getColumnsForTableLabelExpens(String tableName) {
    final normalizedName = tableName.trim().toLowerCase();
    print('Looking for TableName: "$tableName" in matchedDatasets');

    for (var dataset in matchedDatasets) {
      if (dataset is! Map<String, dynamic> || !dataset.containsKey('Schema')) {
        continue;
      }

      final schema = dataset['Schema'];
      if (schema is! Map<String, dynamic> || !schema.containsKey('tables')) {
        continue;
      }

      final tables = schema['tables'];
      if (tables is! List) continue;

      for (var table in tables) {
        if (table is! Map<String, dynamic>) continue;

        final tableNameFromData = (table['TableName'] ?? '')
            .toString()
            .trim()
            .toLowerCase();

        if (tableNameFromData == normalizedName) {
          print("Found matching table: $tableNameFromData");

          if (table['Columns'] is! List) return [];

          final cols = (table['Columns'] as List)
              .where(
                (col) => col is Map<String, dynamic> && col['Colname'] != null,
              )
              .map((col) {
                final colName = col['Colname'].toString();
                final label = col['Label']?.toString() ?? '';
                final type = (col['Type'] ?? '').toString().toLowerCase();

                // Store column type in tableColumnTypes
                tableColumnTypes.putIfAbsent(tableName, () => {});
                tableColumnTypes[tableName]![colName] = type;

                return {'colname': colName, 'label': label};
              })
              .toList();

          return cols;
        }
      }
    }

    return [];
  }

  void addSelectedColumn(String colname) {
    print("ADDcolname$colname");
    if (!selectedCheckbox1.contains(colname)) {
      selectedCheckbox1.add(colname);

      notifyListeners();
    }
    print("ADDcolname${selectedCheckbox1.length}");
  }

  void removeSelectedColumn(String colname) {
    if (selectedCheckbox1.remove(colname)) {
      notifyListeners();
    }
  }

  void addSelectedColumn2(String colname) {
    print("ADDcolname$colname");
    if (!selectedCheckbox2.contains(colname)) {
      selectedCheckbox2.add(colname);

      notifyListeners();
    }
    print("ADDcolname${selectedCheckbox2.length}");
  }

  void removeSelectedColumn2(String colname) {
    if (selectedCheckbox2.remove(colname)) {
      notifyListeners();
    }
  }

  Future<List<String>> fetchDatasetsExpense(String props) async {
    try {
      // Map props to correct API name
      final mapping = {
        "Cash Advance Requisition": "CashAdvanceRequisition",
        "Expense Requisition": "ExpenseRequisition",
      };
      String mappedProp = mapping[props] ?? props;
      comparefunctionalAreaWithRes = mappedProp;
      final response = await http.get(
        Uri.parse('${Urls.expenseReport}$mappedProp'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Create a flat list of all Colname values
        List<String> allColNames = [];
        for (var table in data) {
          if (table['Columns'] != null) {
            for (var col in table['Columns']) {
              if (col['Colname'] != null) {
                allColNames.add(col['Colname']);
              }
            }
          }
        }

        print("Total Colnames: ${allColNames.length}");
        print(allColNames);

        // Optionally still update your state
        updateAllDatasets(allColNames);

        return allColNames; // ✅ return the list here
      } else {
        throw Exception('Failed to load datasets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching datasets: $e');
    }
  }

  Future<void> callMISReportAPI(BuildContext context) async {
    try {
      // 1️⃣ Parse date values safely
      final DateTime fromDate = fromDateCtrl.text.isNotEmpty
          ? DateFormat('dd-MM-yyyy').parse(fromDateCtrl.text)
          : DateTime.now();
      final DateTime toDate = toDateCtrl.text.isNotEmpty
          ? DateFormat('dd-MM-yyyy').parse(toDateCtrl.text)
          : DateTime.now();

      // 2️⃣ Prepare query parameters
      final queryParams = {
        'functionalarea': functionalArea.replaceAll(' ', ''),
        'from_date': fromDate.millisecondsSinceEpoch.toString(),
        'to_date': toDate.millisecondsSinceEpoch.toString(),
        'sort_by': sortBy ?? '',
        'sort_order': sortOrder ?? '',
      };

      // 3️⃣ Build filterGroups JSON
      final filterGroupsJson = filterGroups.asMap().entries.map((entry) {
        final groupIndex = entry.key;
        final group = entry.value;
        final groupOperator = groupOperators[groupIndex];

        final rulesJson = group.map((rule) {
          // 🔹 Get actual column type from tableColumnTypes map
          final colType =
              tableColumnTypes[rule.table]?[rule.column] ?? 'string';

          return {
            "selectedTable": rule.table,
            "selectedField": rule.column,
            "Type": colType, // dynamic type
            "selectedCondition": rule.condition.toLowerCase() == "in between"
                ? "between"
                : rule.condition.toLowerCase().replaceAll(' ', '_'),

            "singleValue": rule.condition.toLowerCase() == 'in between'
                ? ""
                : (rule.value ?? ""),
            "inBetweenValues": rule.condition.toLowerCase() == 'in between'
                ? (rule.inBetweenValues.isNotEmpty
                      ? rule.inBetweenValues
                      : ["", ""])
                : ["", ""],
          };
        }).toList();

        return {"matchType": groupOperator, "rules": rulesJson};
      }).toList();

      // 4️⃣ Build API URL
      final url = Uri.https(
        'api.digixpense.com',
        '/api/v1/reports/expensereport/misreportdata',
        queryParams,
      );

      debugPrint("📡 Request URL: $url");
      debugPrint("📦 Request Body: ${jsonEncode(filterGroupsJson)}");

      // 5️⃣ Make API request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken}',
        },
        body: jsonEncode(filterGroupsJson),
      );

      // 6️⃣ Handle Response
      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = json.decode(response.body);

          if (data.containsKey('data') && data['data'] is List) {
            List<dynamic> expenseList = data['data'];

            // 🔹 Extract & store ExpenseIds
            await _saveExpenseIds(expenseList);
            if (expenseList.isEmpty) {
              Fluttertoast.showToast(
                msg: "No expenses found Please Change the Filtrations",
              );
              return;
            }
            // ignore: use_build_context_synchronously
            Navigator.pushNamed(context, AppRoutes.expensePaginationPage);

            Fluttertoast.showToast(msg: "Report fetched successfully");
          } else {
            debugPrint("⚠️ No 'data' key found in response");
            Fluttertoast.showToast(msg: "No data found");
          }
        } catch (e) {
          debugPrint('⚠️ JSON Parse Error: $e');
          Fluttertoast.showToast(msg: "Invalid data format");
        }
      } else {
        debugPrint('❌ API Error ${response.statusCode}: ${response.body}');
        Fluttertoast.showToast(msg: "Failed to fetch report");
      }
    } catch (e, stack) {
      debugPrint('❌ Exception: $e\n$stack');
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }

  /// 📌 Helper function to save ExpenseIds to local storage
  Future<void> _saveExpenseIds(List<dynamic> expenseList) async {
    List<String> expenseIds = expenseList
        .map((item) => item['ExpenseId']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('expenseIds', expenseIds);

    debugPrint("💾 Saved ExpenseIds: $expenseIds");
  }

  void setFromDate(DateTime date, String formatted) {
    fromDateMillis = date.millisecondsSinceEpoch;
    fromDateCtrl.text = formatted;
    notifyListeners();
  }

  void setToDate(DateTime date, String formatted) {
    toDateMillis = date.millisecondsSinceEpoch;
    toDateCtrl.text = formatted;
    notifyListeners();
  }

  void setSortOrder(String value) {
    sortOrder = value; // value will be 'asc' or 'desc'
    notifyListeners();
  }

  Future<void> saveReport(BuildContext context) async {
    final List<Map<String, dynamic>> filterGroupsData = [];
    for (int i = 0; i < filterGroups.length; i++) {
      final group = filterGroups[i];
      final groupOperator = i < groupOperators.length
          ? groupOperators[i]
          : 'AND';

      final validRules = group
          .where((rule) => rule.table.isNotEmpty && rule.column.isNotEmpty)
          .toList();

      if (validRules.isNotEmpty) {
        filterGroupsData.add({
          'matchType': groupOperator,
          'rules': validRules.map((rule) {
            String apiCondition;
            switch (rule.condition) {
              case 'Equal To':
                apiCondition = 'equal';
                break;
              case 'Not Equal To':
                apiCondition = 'not_equal';
                break;
              case 'Contains':
                apiCondition = 'contains';
                break;
              case 'Starts With':
                apiCondition = 'starts_with';
                break;
              case 'Ends With':
                apiCondition = 'ends_with';
                break;
              case 'Less Than':
                apiCondition = 'less_than';
                break;
              case 'Greater Than':
                apiCondition = 'greater_than';
                break;
              case 'Less Than or Equal':
                apiCondition = 'less_or_equal';
                break;
              case 'Greater Than or Equal':
                apiCondition = 'greater_or_equal';
              case 'Is Not Empty':
                apiCondition = 'is_not_empty';
                break;
                 case 'Is Empty':
                apiCondition = 'is_empty';
                break;
              default:
                apiCondition = 'equal';
            }

            return {
              'selectedTable': rule.table,
              'selectedField': rule.column,
              'Type': _getFieldType(rule.column),
              'selectedCondition': apiCondition,
              'singleValue': rule.value,
              'inBetweenValues': ['', ''],
            };
          }).toList(),
        });
      }
    }

    final columnChooserData = [
      {
        'header': {
          'ExpenseId': selectedCheckbox1.contains('ExpenseId'),
          'ProjectId': selectedCheckbox1.contains('ProjectId'),
          'PaymentMethod': selectedCheckbox1.contains('PaymentMethod'),
          'TotalAmountTrans': selectedCheckbox1.contains('TotalAmountTrans'),
          'TotalAmountReporting': selectedCheckbox1.contains(
            'TotalAmountReporting',
          ),
          'ExpenseCategoryId': selectedCheckbox1.contains('ExpenseCategoryId'),
          'MerchantName': selectedCheckbox1.contains('MerchantName'),
          'MerchantId': selectedCheckbox1.contains('MerchantId'),
          'TotalApprovedAmount': selectedCheckbox1.contains(
            'TotalApprovedAmount',
          ),
          'TotalRejectedAmount': selectedCheckbox1.contains(
            'TotalRejectedAmount',
          ),
          'EmployeeId': selectedCheckbox1.contains('EmployeeId'),
          'ReceiptDate': selectedCheckbox1.contains('ReceiptDate'),
          'ApprovalStatus': selectedCheckbox1.contains('ApprovalStatus'),
          'Currency': selectedCheckbox1.contains('Currency'),
          'ReferenceNumber': selectedCheckbox1.contains('ReferenceNumber'),
          'Description': selectedCheckbox1.contains('Description'),
          'IsBillable': selectedCheckbox1.contains('IsBillable'),
          'RecId': selectedCheckbox1.contains('RecId'),
          'TaxGroup': selectedCheckbox1.contains('TaxGroup'),
          'TaxAmount': selectedCheckbox1.contains('TaxAmount'),
          'IsReimbursable': selectedCheckbox1.contains('IsReimbursable'),
          'Country': selectedCheckbox1.contains('Country'),
          'Location': selectedCheckbox1.contains('Location'),
          'FromDate': selectedCheckbox1.contains('FromDate'),
          'ToDate': selectedCheckbox1.contains('ToDate'),
          'ExpenseType': selectedCheckbox1.contains('ExpenseType'),
        },
      },
      {
        'lines': {
          'LineNumber': selectedCheckbox2.contains('LineNumber'),
          'ExpenseCategoryId': selectedCheckbox2.contains('ExpenseCategoryId'),
          'Timezone': selectedCheckbox2.contains('Timezone'),
          'Quantity': selectedCheckbox2.contains('Quantity'),
          'UomId': selectedCheckbox2.contains('UomId'),
          'UnitPriceTrans': selectedCheckbox2.contains('UnitPriceTrans'),
          'UnitPriceReporting': selectedCheckbox2.contains(
            'UnitPriceReporting',
          ),
          'LineAmountTrans': selectedCheckbox2.contains('LineAmountTrans'),
          'LineAmountReporting': selectedCheckbox2.contains(
            'LineAmountReporting',
          ),
          'TaxAmount': selectedCheckbox2.contains('TaxAmount'),
          'TaxGroup': selectedCheckbox2.contains('TaxGroup'),
          'AmountSettled': selectedCheckbox2.contains('AmountSettled'),
          'LastSettlementDate': selectedCheckbox2.contains(
            'LastSettlementDate',
          ),
          'ClosedDate': selectedCheckbox2.contains('ClosedDate'),
          'ApprovedAmount': selectedCheckbox2.contains('ApprovedAmount'),
          'RejectedAmount': selectedCheckbox2.contains('RejectedAmount'),
          'RecId': selectedCheckbox2.contains('RecId'),
          'ProjectId': selectedCheckbox2.contains('ProjectId'),
          'Description': selectedCheckbox2.contains('Description'),
          'IsReimbursable': selectedCheckbox2.contains('IsReimbursable'),
          'EmployeeId': selectedCheckbox2.contains('EmployeeId'),
          'ExpenseId': selectedCheckbox2.contains('ExpenseId'),
          'Location': selectedCheckbox2.contains('Location'),
          'FromDate': selectedCheckbox2.contains('FromDate'),
          'ToDate': selectedCheckbox2.contains('ToDate'),
        },
      },
    ];

    final payload = {
      'Reports': {
        'Name': reportName.text,
        'DataSet': int.tryParse(dataSet) ?? 0,
        'ReportAvailability': applicableFor,
        'FunctionalArea': functionalArea == 'Expense Requisition'
            ? 'ExpenseRequisition'
            : 'CashAdvanceRequisition',
        'ColumnChooser': jsonEncode(columnChooserData),
        'ReportMetaData': jsonEncode(filterGroupsData),
        'Description': description.text,
        'AvailableFor': tags.text,
        'RecId': int.tryParse(resrecID) ?? 0,
      },
      'ReportUserMappings': finelselectedUsers.isNotEmpty
          ? finelselectedUsers.map((user) {
              return {
                'RefRecId': 0,
                'UserId': user.userId, // or user.email if that's the field
              };
            }).toList()
          : [],
    };

    try {
      final response = await http.post(
        Uri.parse(
          'https://api.digixpense.com/api/v1/reports/reports/reportandreportusermapping',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken}',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 280) {
        final responseData = jsonDecode(response.body);
        Navigator.pushNamed(context, AppRoutes.reportsDashboard);
        resetForm();
        Fluttertoast.showToast(
          msg: responseData['detail']['message'] ?? 'Report saved successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(
          errorResponse['detail']['message'] ??
              'Failed to save report (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error saving report: ${e.toString()}')),
      // );
      rethrow;
    }
  }

  String _getFieldType(String columnName) {
    if (columnName.toLowerCase().contains('date')) return 'date';
    if (columnName.toLowerCase().contains('amount')) return 'number';
    return 'string';
  }
}
