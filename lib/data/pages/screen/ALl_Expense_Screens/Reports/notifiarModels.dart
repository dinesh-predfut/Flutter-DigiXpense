import 'package:digi_xpense/data/models.dart';
import 'package:flutter/material.dart';

class ReportModel with ChangeNotifier {
  String _reportName = '';
  String _functionalArea = '';
  String _dataSet = '';
  String _description = '';
  String _tags = '';
  String _applicableFor = '';
  List<FilterRule> _filterRules = [];
  List<String> _selectedFields = [];

  String get reportName => _reportName;
  String get functionalArea => _functionalArea;
  String get dataSet => _dataSet;
  String get description => _description;
  String get tags => _tags;
  String get applicableFor => _applicableFor;
  List<FilterRule> get filterRules => _filterRules;
  List<String> get selectedFields => _selectedFields;

  void updateReportName(String value) {
    _reportName = value;
    notifyListeners();
  }

  void updateFunctionalArea(String value) {
    _functionalArea = value;
    notifyListeners();
  }

  void updateDataSet(String value) {
    _dataSet = value;
    notifyListeners();
  }

  void updateDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void updateTags(String value) {
    _tags = value;
    notifyListeners();
  }

  void updateApplicableFor(String value) {
    _applicableFor = value;
    notifyListeners();
  }

  void addFilterRule() {
    _filterRules.add(FilterRule(table: '', column: '', condition: '', value: ''));
    notifyListeners();
  }

  void removeFilterRule(int index) {
    _filterRules.removeAt(index);
    notifyListeners();
  }

  void updateFilterRule(int index, String field, dynamic value) {
    switch (field) {
      case 'table':
        _filterRules[index].table = value;
        break;
      case 'column':
        _filterRules[index].column = value;
        break;
      case 'condition':
        _filterRules[index].condition = value;
        break;
      case 'value':
        _filterRules[index].value = value;
        break;
    }
    notifyListeners();
  }

  void addSelectedField(String field) {
    _selectedFields.add(field);
    notifyListeners();
  }

  void removeSelectedField(String field) {
    _selectedFields.remove(field);
    notifyListeners();
  }
}