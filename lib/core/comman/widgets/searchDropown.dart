import 'package:flutter/material.dart';

class SearchableMultiColumnDropdownField<T> extends StatefulWidget {
  final String labelText;
  final List<String> columnHeaders;
  final List<T> items;
  final String Function(T) searchValue;
  final void Function(T?) onChanged;
  final Widget Function(T) rowBuilder;
  final String? Function(T?)? validator;
  final String Function(T) displayText;
  final T? selectedValue; // ✅ NEW PARAM

  const SearchableMultiColumnDropdownField({
    Key? key,
    required this.labelText,
    required this.columnHeaders,
    required this.items,
    required this.searchValue,
    required this.onChanged,
    required this.rowBuilder,
    required this.displayText,
    this.validator,
    this.selectedValue, // ✅ INCLUDE
  }) : super(key: key);

  @override
  State<SearchableMultiColumnDropdownField<T>> createState() =>
      _SearchableMultiColumnDropdownFieldState<T>();
}

class _SearchableMultiColumnDropdownFieldState<T>
    extends State<SearchableMultiColumnDropdownField<T>> {
  final TextEditingController _controller = TextEditingController();
  String _searchQuery = '';
  bool _showResults = false;
  bool _didInit = false;
  T? _selectedItem;

  @override
  void initState() {
    super.initState();

    // ✅ Preselect value from widget.selectedValue
    if (widget.selectedValue != null) {
      _selectedItem = widget.selectedValue;
      _controller.text = widget.displayText(widget.selectedValue as T);
    }

    _controller.addListener(() {
      final value = _controller.text;
      setState(() {
        _searchQuery = value;
        _showResults = value.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _searchQuery.isEmpty
        ? widget.items
        : widget.items
            .where((item) => widget
                .searchValue(item)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();

    return FormField<T>(
      initialValue: _selectedItem,
      validator: widget.validator,
      builder: (fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '${widget.labelText}*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchQuery.isEmpty
                    ? const Icon(Icons.arrow_drop_down_outlined)
                    : GestureDetector(
                        onTap: () {
                          setState(() {
                            _controller.clear();
                            _searchQuery = '';
                            _showResults = false;
                            _selectedItem = null;
                          });
                          fieldState.didChange(null);
                          widget.onChanged(null);
                        },
                        child: const Icon(Icons.clear),
                      ),
              ),
              onTap: () {
                if (_controller.text.isEmpty) {
                  setState(() => _showResults = true);
                }
              },
            ),
            const SizedBox(height: 8),
            if (_showResults)
              Container(
                constraints: const BoxConstraints(maxHeight: 250),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      color: Colors.grey.shade200,
                      child: Row(
                        children: widget.columnHeaders
                            .map((header) => Expanded(
                                  child: Text(
                                    header,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const Divider(height: 1),
                    // Items
                    Expanded(
                      child: filteredItems.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text('No matching results'),
                            )
                          : ListView.builder(
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                return InkWell(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    final text = widget.displayText(item);
                                    _controller.text = text;
                                    _searchQuery = '';
                                    _showResults = false;
                                    _selectedItem = item;
                                    fieldState.didChange(item);
                                    widget.onChanged(item);
                                  },
                                  child: widget.rowBuilder(item),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            if (fieldState.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 12),
                child: Text(
                  fieldState.errorText!,
                  style: TextStyle(color: Theme.of(context).errorColor),
                ),
              ),
          ],
        );
      },
    );
  }
}
