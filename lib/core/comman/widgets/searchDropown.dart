import 'package:flutter/material.dart';

/// A multi‐column dropdown that fetches and displays items from an API as you type,
/// rendered inline rather than via an OverlayEntry.
class MultiColumnSearchDropdownField<T> extends StatefulWidget {
  final FormFieldState<T> state;
  final String labelText;
  /// Column headers to show above the results
  final List<String> columnHeaders;
  /// Called when the user selects an item
  final void Function(T?) onChanged;
  /// Builds a row for each item
  final Widget Function(T item) rowBuilder;
  /// Displays the selected item in the field
  final String Function(T selected) selectedDisplay;
  /// As-you-type search: returns a Future list from API
  final Future<List<T>> Function(String query) onSearch;
  /// Maximum height of dropdown
  final double dropdownHeight;

  const MultiColumnSearchDropdownField({
    Key? key,
    required this.state,
    required this.labelText,
    required this.columnHeaders,
    required this.onChanged,
    required this.rowBuilder,
    required this.selectedDisplay,
    required this.onSearch,
    required this.dropdownHeight,
  }) : super(key: key);

  @override
  State<MultiColumnSearchDropdownField<T>> createState() =>
      _MultiColumnSearchDropdownFieldState<T>();
}

class _MultiColumnSearchDropdownFieldState<T>
    extends State<MultiColumnSearchDropdownField<T>> {
  late FocusNode _focusNode;
  String _searchQuery = '';
  List<T> _items = [];
  bool _loading = false;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    // Close on focus loss
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isOpen) {
        setState(() => _isOpen = false);
      }
    });
  }

  Future<void> _fetchItems(String query) async {
    setState(() => _loading = true);
    try {
      final results = await widget.onSearch(query);
      setState(() => _items = results);
    } catch (_) {
      setState(() => _items = []);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _toggleDropdown() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen && _items.isEmpty) {
        _fetchItems('');
      }
      if (_isOpen) {
        _focusNode.requestFocus();
      } else {
        _focusNode.unfocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.state.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The main field
        GestureDetector(
          onTap: _toggleDropdown,
          child: InputDecorator(
            isEmpty: selected == null,
            decoration: InputDecoration(
              labelText: widget.labelText,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
              errorText: widget.state.errorText,
              suffixIcon:
                  Icon(_isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            ),
            child: Text(
              selected == null ? '' : widget.selectedDisplay(selected),
              style:
                  TextStyle(color: selected == null ? Colors.grey : Colors.black),
            ),
          ),
        ),

        // Inline dropdown
        if (_isOpen)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: BoxConstraints(maxHeight: widget.dropdownHeight),
            child: Column(
              children: [
                // Search input
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    focusNode: _focusNode,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Type to search...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      _searchQuery = val;
                      _fetchItems(val);
                    },
                  ),
                ),

                // Headers row
                Container(
                  color: Colors.grey[200],
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    children: widget.columnHeaders
                        .map((h) => Expanded(
                            child: Text(h,
                                style:
                                    const TextStyle(fontWeight: FontWeight.bold))))
                        .toList(),
                  ),
                ),
                const Divider(height: 1),

                // Results list / loading / empty
                Flexible(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _items.isEmpty
                          ? const Center(child: Text('No results'))
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: _items.length,
                              itemBuilder: (_, i) {
                                final item = _items[i];
                                return InkWell(
                                  onTap: () {
                                    widget.state.didChange(item);
                                    widget.onChanged(item);
                                    setState(() => _isOpen = false);
                                    _focusNode.unfocus();
                                  },
                                  child: widget.rowBuilder(item),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
