import 'package:flutter/material.dart';

class CommonFilterTabs extends StatelessWidget {
  final List<String> filterOptions;
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const CommonFilterTabs({
    Key? key,
    required this.filterOptions,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filterOptions.map((filter) {
          final isSelected = selectedFilter == filter;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              child: ElevatedButton(
                onPressed: () => onFilterChanged(filter),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.black : Colors.white,
                  foregroundColor: isSelected ? Colors.white : Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
} 