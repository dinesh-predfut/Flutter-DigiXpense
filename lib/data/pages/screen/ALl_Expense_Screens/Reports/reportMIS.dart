import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../models.dart';

// Enhanced Rule Model for read-only view
// class Rule {
//   final String table;
//   final String column;
//   final String condition;
//   final String value;
//   final List<String> inBetweenValues;

//   const Rule({
//     required this.table,
//     required this.column,
//     required this.condition,
//     required this.value,
//     required this.inBetweenValues,
//   });

//   String get displayValue {
//     if (condition == 'In Between') {
//       return '${inBetweenValues.getOrNull(0) ?? ''} and ${inBetweenValues.getOrNull(1) ?? ''}';
//     }
//     if (condition == 'Is Empty' || condition == 'Is Not Empty') {
//       return '';
//     }
//     return '"$value"';
//   }

//   List<String> get availableColumns {
//     switch (table) {
//       case 'Employees':
//         return ['First Name', 'Last Name', 'Employee ID', 'Department'];
//       case 'Expenses':
//         return ['Amount', 'Category', 'Date', 'Status'];
//       case 'Vendors':
//         return ['Vendor Name', 'GST', 'Location'];
//       default:
//         return [];
//     }
//   }

//   List<String> get conditionItems {
//     if (column.isEmpty) return [];
//     final typeBased = _inferColumnType() == 'text'
//         ? ['Equal To', 'Not Equal To', 'Contains', 'Is Empty', 'Is Not Empty']
//         : ['Equal To', 'Not Equal To', 'Greater Than', 'Less Than', 'In Between', 'Is Empty', 'Is Not Empty'];
//     return typeBased;
//   }

//   String _inferColumnType() {
//     final textFields = ['First Name', 'Last Name', 'Department', 'Category', 'Status', 'Vendor Name', 'Location'];
//     return textFields.contains(column) ? 'text' : 'number';
//   }
// }

// Extension to safely access list items
extension ListExtension<T> on List<T> {
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}

// Example Data Model


class ReportScreen extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final  List<Rule> rules; // Pass existing rules from API
  final String logicalOperator; // AND or OR

  const ReportScreen({
    Key? key,
    required this.data,
    required this.rules,
    required this.logicalOperator,
  }) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late List<Map<String, dynamic>> _data;
  String _logicalOperator = 'AND';
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _data = List.from(widget.data);
    _logicalOperator = widget.logicalOperator;
  }

  Future<void> _applyFilters() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }
 Future<void> _exportToExcel() async {
    if (_data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to export!')),
      );
      return;
    }

    final excel = Excel.createExcel();
    final sheet = excel['Report'];

    // Header
    sheet.appendRow([
      TextCellValue('Merchant Name'),
      TextCellValue('Total Rejected Amount'),
      TextCellValue('Employee ID'),
      TextCellValue('Tax Amount'),
      TextCellValue('Last Settlement Date'),
    ]);

    // Data
    for (var row in _data) {
      sheet.appendRow([
        TextCellValue(row['MerchantName']?.toString() ?? ''),
        TextCellValue(row['TotalRejectedAmount']?.toString() ?? '0.00'),
        TextCellValue(row['EmployeeId']?.toString() ?? ''),
        TextCellValue(row['TaxAmount']?.toString() ?? '0.00'),
        TextCellValue(row['LastSettlementDate']?.toString() ?? ''),
      ]);
    }

    try {
      final bytes = excel.save()!;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/Expense_Report.xlsx');
      await file.writeAsBytes(bytes);

      final result = await OpenFilex.open(file.path);
      if (result.type == ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exported and opened Excel file!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open: ${result.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }
// Future<void> _exportToExcel() async {
//   if (_data.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('No data to export!')),
//     );
//     return;
//   }

//   final excel = Excel.createExcel();
//   final sheet = excel['Report'];

//   // Header
//   sheet.appendRow([
//     TextCellValue('Merchant Name'),
//     TextCellValue('Total Rejected Amount'),
//     TextCellValue('Employee ID'),
//     TextCellValue('Tax Amount'),
//     TextCellValue('Last Settlement Date'),
//   ]);

//   // Data
//   for (var row in _data) {
//     sheet.appendRow([
//       TextCellValue(row['MerchantName']?.toString() ?? ''),
//       TextCellValue(row['TotalRejectedAmount']?.toString() ?? '0.00'),
//       TextCellValue(row['EmployeeId']?.toString() ?? ''),
//       TextCellValue(row['TaxAmount']?.toString() ?? '0.00'),
//       TextCellValue(row['LastSettlementDate']?.toString() ?? ''),
//     ]);
//   }

//   try {
//     final bytes = excel.save()!;

//     Directory? dir;

//     if (Platform.isAndroid) {
//       // Check and request storage permission if needed (for Android < 11)
//       if (await _requestStoragePermission()) {
//         // Try to use Downloads folder first
//         dir = Directory('/storage/emulated/0/Download');
//         if (!dir.existsSync()) {
//           // Fallback to app-specific external storage directory
//           dir = await getExternalStorageDirectory();
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Storage permission denied')),
//         );
//         return;
//       }
//     } else if (Platform.isIOS) {
//       dir = await getApplicationDocumentsDirectory();
//     } else {
//       dir = await getApplicationDocumentsDirectory();
//     }

//     final filePath =
//         '${dir!.path}/Expense_Report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
//     final file = File(filePath);

//     await file.writeAsBytes(bytes);

//     final result = await OpenFilex.open(file.path);
//     if (result.type == ResultType.done) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Exported and opened Excel file at $filePath')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to open: ${result.message}')),
//       );
//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Export failed: $e')),
//     );
//   }
// }

// // Helper function to request storage permission on Android
// Future<bool> _requestStoragePermission() async {
//   var status = await Permission.storage.status;
//   if (!status.isGranted) {
//     status = await Permission.storage.request();
//   }
//   return status.isGranted;
// } 

  Widget _chip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        // border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

 Widget _buildRuleCard(Rule rule, int index) {
  // Determine if this is a read-only view (for existing reports)
  final isEditableField = rule.selectedField == null;
  
  return Container(
    padding: const EdgeInsets.all(12.0),
    decoration: BoxDecoration(
      // color: Colors.grey[100],
      borderRadius: BorderRadius.circular(8),
      // border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Read-only display for existing reports
     
          // Row(
          //   children: [
          //     // Table
          //     _chip(rule.selectedTable, Colors.blue.shade100, Colors.blue.shade800),
          //     const SizedBox(width: 8),
          //     const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
          //     const SizedBox(width: 8),
              
          //     // Column
          //     _chip(rule.selectedField, Colors.green.shade100, Colors.green.shade800),
          //     const SizedBox(width: 8),
          //     const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
          //     const SizedBox(width: 8),
              
          //     // Condition
          //     _chip(rule.selectedCondition, Colors.orange.shade100, Colors.orange.shade800),
              
          //     if (rule.selectedTable.isNotEmpty) ...[
          //       const SizedBox(width: 8),
          //       const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
          //       const SizedBox(width: 8),
          //       // Value
          //       Expanded(
          //         child: Container(
          //           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          //           decoration: BoxDecoration(
          //             color: Colors.grey.shade200,
          //             borderRadius: BorderRadius.circular(6),
          //           ),
          //           child: Text(
          //             rule.singleValue,
          //             style: const TextStyle(
          //               fontSize: 13,
          //               fontFamily: 'monospace',
          //               fontWeight: FontWeight.w500,
          //             ),
          //             overflow: TextOverflow.ellipsis,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ],
          // ),
        
        
        // Editable fields for new reports
     
          LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56, maxHeight: 400),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomDropdown(
                        labelText: AppLocalizations.of(context)!.table,
                        items: const ['Employees', 'Expenses', 'Vendors'], // Replace with your actual table labels
                        value: rule.selectedTable.isEmpty ? null : rule.selectedTable,
                        onChanged: (value) {
                          if (value != null) {
                            // Handle table selection change
                            // You'll need to implement this logic
                          }
                        },
                        isEditable: isEditableField,
                      ),
                      const SizedBox(height: 16),
                      
                      if (rule.selectedField.isNotEmpty) 
                        CustomDropdown(
                          labelText: AppLocalizations.of(context)!.column,
                           items: const ["Name", "Amount", "Date", "Status", "Category", "ID"],
                          value: rule.selectedField,
                          onChanged: (value) {
                            if (value != null) {
                              // Handle column selection change
                            }
                          },
                          isEditable: isEditableField,
                        ),
                      
                      if (rule.selectedField.isNotEmpty) const SizedBox(height: 16),
                      
                      if (rule.selectedField.isNotEmpty)
                        CustomDropdown(
                          labelText:AppLocalizations.of(context)!.condition,
                         items: const ["Employees", "Expenses", "Vendors", "Departments", "Projects"],
                          value: rule.selectedCondition.isEmpty ? null : rule.selectedCondition,
                          onChanged: (value) {
                            if (value != null) {
                              // Handle condition selection change
                            }
                          },
                          isEditable: isEditableField,
                        ),
                      
                      if (rule.selectedCondition.isNotEmpty) const SizedBox(height: 16),
                      
                      if (rule.selectedCondition.isNotEmpty && rule.selectedCondition != "In Between")
                        const SizedBox(height: 16),
                      
                      if (rule.selectedCondition.isNotEmpty && 
                          rule.selectedCondition != "In Between" &&
                          rule.selectedCondition != "Is Not Empty" &&
                          rule.selectedCondition != "Is Empty")
                        SizedBox(
                          width: double.infinity,
                          child: TextFormField(
                            initialValue: rule.singleValue,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.value,
                              hintText: AppLocalizations.of(context)!.enterValueToMatch,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue.shade400),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                            onChanged: (value) {
                              // Handle value change
                            },
                          ),
                        ),
                      
                      if (rule.selectedCondition.isNotEmpty && rule.selectedCondition == "In Between") ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: TextFormField(
                            initialValue: rule.inBetweenValues.isNotEmpty ? rule.inBetweenValues[0] : '',
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.from,
                              hintText: AppLocalizations.of(context)!.enterStartingValue,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue.shade400),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                            onChanged: (val) {
                              // Handle "from" value change
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: TextFormField(
                            initialValue: rule.inBetweenValues.length > 1 ? rule.inBetweenValues[1] : '',
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.to,
                              hintText: AppLocalizations.of(context)!.enterEndingValue,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue.shade400),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                            onChanged: (val) {
                              // Handle "to" value change
                            },
                          ),
                        ),
                   
                      
                      if (isEditableField)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                            label:  Text(AppLocalizations.of(context)!.removeRule, style: const TextStyle(color: Colors.red)),
                            onPressed: () {
                              // Handle rule removal
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                          ),
                        ),
                    ],
       ] )
                ),
              );
            },
          ),
        ],
        
      
      
    ),
  );
}

// You'll also need to add the CustomDropdown widget if it doesn't exist


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(AppLocalizations.of(context)!.generateReport),
        // backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             AndOrToggleButton(value:_logicalOperator, onChanged: (String value) {  },),
            // AND / OR Logic Toggle
            // Row(
            //   children: [
            //     TextButton(
            //       onPressed: () => setState(() => _logicalOperator = 'AND'),
            //       child: Text(
            //         'AND',
            //         style: TextStyle(
            //           color: _logicalOperator == 'AND' ? Colors.blue : Colors.grey,
            //           fontWeight: _logicalOperator == 'AND' ? FontWeight.bold : null,
            //         ),
            //       ),
            //     ),
               
            //     TextButton(
            //       onPressed: () => setState(() => _logicalOperator = 'OR'),
            //       child: Text(
            //         'OR',
            //         style: TextStyle(
            //           color: _logicalOperator == 'OR' ? Colors.blue : Colors.grey,
            //           fontWeight: _logicalOperator == 'OR' ? FontWeight.bold : null,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 16),

            // Filters (Read-Only)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  AppLocalizations.of(context)!.filterRule,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.rules.map((rule) {
                    return _buildRuleCard(rule, 0); // Index not used since non-editable
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search & Export
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration:  InputDecoration(
                      hintText: AppLocalizations.of(context)!.search,
                      prefixIcon: const Icon(Icons.search, size: 16),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _exportToExcel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child:  Text(AppLocalizations.of(context)!.export, style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Apply Filters Button
            ElevatedButton(
              onPressed: _applyFilters,
              child:  Text(AppLocalizations.of(context)!.applyFilters),
            ),
            const SizedBox(height: 16),

            // Loading Indicator
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_data.isEmpty)
               Center(child: Text(AppLocalizations.of(context)!.noDataFound))
            else
              // Expandable Results
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _data.length,
                itemBuilder: (context, index) {
                  final item = _data[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                    child: ExpansionTile(
                      title: Text(
                        '${AppLocalizations.of(context)!.merchantName}: ${item['MerchantName']}, '
                        '${AppLocalizations.of(context)!.totalRejectedAmount} ${item['TotalRejectedAmount']}, '
                        '${AppLocalizations.of(context)!.employeeId}: ${item['EmployeeId']}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      children: [
                        ListTile(
                          title:  Text(AppLocalizations.of(context)!.taxAmount),
                          subtitle: Text(item['TaxAmount']?.toString() ?? '0.00'),
                        ),
                        ListTile(
                          title:  Text(AppLocalizations.of(context)!.lastSettlementDate),
                          subtitle: Text(item['LastSettlementDate']?.toString() ?? '-'),
                        ),
                      ],
                    ),
                  );
                },
              ),
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
  final Function(String?)? onChanged;
  final bool isEditable;

  const CustomDropdown({
    Key? key,
    required this.labelText,
    required this.items,
    this.value,
    this.onChanged,
    required this.isEditable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: !isEditable, // disables input when not editable
      initialValue: value ?? "",
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        suffixIcon: isEditable
            ? PopupMenuButton<String>(
                icon: const Icon(Icons.arrow_drop_down),
                onSelected: onChanged,
                itemBuilder: (BuildContext context) {
                  return items.map((String item) {
                    return PopupMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList();
                },
              )
            : null,
      ),
      onChanged: isEditable ? (val) => onChanged?.call(val) : null,
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