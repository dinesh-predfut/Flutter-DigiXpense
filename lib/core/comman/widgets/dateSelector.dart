import 'package:digi_xpense/core/comman/widgets/multiColumnDropdown.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DateFormatDropdown extends StatelessWidget {
  final Function(MapEntry<String, String>?) onChanged;
  final MapEntry<String, String>? selectedEntry;

   DateFormatDropdown({
    super.key,
    required this.onChanged,
    this.selectedEntry,
  });
 Map<String, String> dateFormatMap = {
  'mm_dd_yyyy': 'MM/dd/yyyy',
  'dd_mm_yyyy': 'dd/MM/yyyy',
  'yyyy_mm_dd': 'yyyy/MM/dd',
  'mm_dd_yyyy_dash': 'MM-dd-yyyy',
  'dd_mm_yyyy_dash': 'dd-MM-yyyy',
  'yyyy_mm_dd_dash': 'yyyy-MM-dd',
  'mm_dd_yyyy_dot': 'MM.dd.yyyy',
  'dd_mm_yyyy_dot': 'dd.MM.yyyy',
  'yyyy_mm_dd_dot': 'yyyy.MM.dd',
  'MM_dd_yyyy': 'MM/dd/yyyy',
  'dd_MM_yyyy': 'dd/MM/yyyy',
  'YYYY_MM_DD': 'yyyy/MM/dd',
  'MM_dd_yyyy_dash_alt': 'MM-dd-yyyy',
  'dd_MM_yyyy_dash_alt': 'dd-MM-yyyy',
  'YYYY_MM_DD_dash_alt': 'yyyy-MM-dd',
  'MM_dd_yyyy_dot_alt': 'MM.dd.yyyy',
  'dd_MM_yyyy_dot_alt': 'dd.MM.yyyy',
  'YYYY_MM_DD_dot_alt': 'yyyy.MM.dd',
};

  @override
  Widget build(BuildContext context) {
    return FormField<MapEntry<String, String>>(
      builder: (state) {
        return MultiColumnDropdownField<MapEntry<String, String>>(
          state: state,
          labelText: 'Select Date Format',
          columnHeaders: const ['Key', 'Format'],
          items: dateFormatMap.entries.toList(),
          dropdownHeight: 300,
          onChanged: onChanged,
          rowBuilder: (entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              children: [
                Expanded(child: Text(entry.key)),
                Expanded(child: Text(entry.value)),
              ],
            ),
          ),
          selectedDisplay: (entry) => '${entry.key}  (${entry.value})',
        );
      },
      initialValue: selectedEntry,
    );
  }
}
