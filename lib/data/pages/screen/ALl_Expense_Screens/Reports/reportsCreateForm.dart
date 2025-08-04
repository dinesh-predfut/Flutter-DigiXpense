import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/Reports/notifiarModels.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:provider/provider.dart';

class ReportCreateScreen extends StatefulWidget {
  const ReportCreateScreen({super.key});

  @override
  _ReportCreateScreenState createState() => _ReportCreateScreenState();
}

class _ReportCreateScreenState extends State<ReportCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final reportModel = Provider.of<ReportModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Report'),
        elevation: 1,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Report Name ---
                _buildTextField(
                  label: 'Report Name *',
                  hint: 'Enter report title',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                  onChanged: (value) => reportModel.updateReportName(value),
                ),
                const SizedBox(height: 16),

                // --- Functional Area ---
                _buildDropdownField(
                  label: 'Functional Area *',
                  items: const [
                    'Expense Requisition',
                    'Cash Advance Requisition',
                    'Travel Requisition',
                    'Leave Requisition'
                  ],
                  value: reportModel.functionalArea.isEmpty ? null : reportModel.functionalArea,
                  onChanged: (value) => reportModel.updateFunctionalArea(value!),
                ),
                const SizedBox(height: 16),

                // --- Data Set ---
                _buildDropdownField(
                  label: 'Data Set *',
                  items: const ['DataSet of Expense', 'DataSet of Employee'],
                  value: reportModel.dataSet.isEmpty ? null : reportModel.dataSet,
                  onChanged: (value) => reportModel.updateDataSet(value!),
                ),
                const SizedBox(height: 16),

                // --- Description ---
                _buildTextField(
                  label: 'Description',
                  hint: 'Add a short description (optional)',
                  maxLines: 3,
                  onChanged: (value) => reportModel.updateDescription(value),
                ),
                const SizedBox(height: 16),

                // --- Tags ---
                _buildDropdownField(
                  label: 'Tags',
                  items: const ['Tags'],
                  value: reportModel.tags.isEmpty ? null : reportModel.tags,
                  onChanged: (value) => reportModel.updateTags(value!),
                ),
                const SizedBox(height: 16),

                // --- Applicable For ---
                _buildDropdownField(
                  label: 'Applicable For *',
                  items: const ['Public', 'Private', 'Specific Users'],
                  value: reportModel.applicableFor.isEmpty ? null : reportModel.applicableFor,
                  onChanged: (value) => reportModel.updateApplicableFor(value!),
                ),
                const SizedBox(height: 24),

                // --- Filter Rules Section ---
                const Text(
                  'Filter Rules',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 8),

                // Add Rule Button
                ElevatedButton.icon(
                  onPressed: () => reportModel.addFilterRule(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Rule'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // List of Filter Rules
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reportModel.filterRules.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return _buildFilterRuleCard(reportModel.filterRules[index], index);
                  },
                ),

                const SizedBox(height: 24),

                // --- Save Button ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        // Simulate save
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Success!'),
                            content: const Text('Your report has been saved successfully.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Save Report',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable Text Field
  Widget _buildTextField({
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }

  // Reusable Dropdown Field
  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      isExpanded: true,
    );
  }

  // Filter Rule Card with Horizontal Scroll
  Widget _buildFilterRuleCard(FilterRule rule, int index) {
    final reportModel = Provider.of<ReportModel>(context, listen: false);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Horizontal Scrollable Rule Row
            SizedBox(
              height: 60,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: 160,
                      child: DropdownButtonFormField<String>(
                        value: rule.table.isEmpty ? null : rule.table,
                        decoration: _dropdownInputDecoration('Table'),
                        items: ['Employees', 'Expense Trans']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (value) => reportModel.updateFilterRule(index, 'table', value!),
                        isExpanded: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 160,
                      child: DropdownButtonFormField<String>(
                        value: rule.column.isEmpty ? null : rule.column,
                        decoration: _dropdownInputDecoration('Column'),
                        items: _getColumnsForTable(rule.table)
                            .map((col) => DropdownMenuItem(value: col, child: Text(col)))
                            .toList(),
                        onChanged: (value) => reportModel.updateFilterRule(index, 'column', value!),
                        isExpanded: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 160,
                      child: DropdownButtonFormField<String>(
                        value: rule.condition.isEmpty ? null : rule.condition,
                        decoration: _dropdownInputDecoration('Condition'),
                        items: [
                          'Equal To',
                          'Not Equal To',
                          'Contains',
                          'Starts With',
                          'Ends With'
                        ]
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (value) => reportModel.updateFilterRule(index, 'condition', value!),
                        isExpanded: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 160,
                      child: TextFormField(
                        initialValue: rule.value,
                        decoration: _textInputDecoration('Value'),
                        onChanged: (value) => reportModel.updateFilterRule(index, 'value', value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete Button
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => reportModel.removeFilterRule(index),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable InputDecoration for Dropdowns
  InputDecoration _dropdownInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      isDense: true,
    );
  }

  // Reusable InputDecoration for TextFields
  InputDecoration _textInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      isDense: true,
    );
  }

  
  List<String> _getColumnsForTable(String table) {
    switch (table) {
      case 'Employees':
        return ['Employee Id', 'First Name', 'Last Name', 'Email', 'Department'];
      case 'Expense Trans':
        return ['Trans ID', 'Amount', 'Date', 'Status', 'Category'];
      default:
        return ['Select table first'];
    }
  }
}