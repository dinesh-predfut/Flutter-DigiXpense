import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MultiSelectMultiColumnDropdownField<T> extends StatefulWidget {
  final String? labelText;
  final List<String> columnHeaders;
  final List<T> items;
  final String Function(T) searchValue;
  final void Function(T?) onChanged;
  final void Function(List<T>)? onMultiChanged; // New callback for multi-select
  final Widget Function(T, String searchQuery) rowBuilder;
  final String? Function(T?)? validator;
  final String? Function(List<T>)?
      multiValidator; // New validator for multi-select
  final String Function(T) displayText;
  final T? selectedValue;
  final List<T>? selectedValues; // New property for multi-select
  final Color? backgroundColor;
  final InputDecoration? inputDecoration;
  final double dropdownMaxHeight;
  final double? dropdownWidth;
  final double? alignLeft;
  final bool? enabled;
  final TextEditingController? controller;
  final bool isMultiSelect; // Flag to determine if multi-select is enabled

  const MultiSelectMultiColumnDropdownField({
    Key? key,
    required this.labelText,
    required this.columnHeaders,
    required this.items,
    required this.searchValue,
    required this.onChanged,
    this.onMultiChanged,
    required this.rowBuilder,
    required this.displayText,
    this.validator,
    this.multiValidator,
    this.selectedValue,
    this.selectedValues,
    this.backgroundColor,
    this.inputDecoration,
    this.dropdownMaxHeight = 180,
    this.dropdownWidth,
    this.alignLeft,
    this.enabled,
    this.controller,
    required this.isMultiSelect, // Make this required
  }) : super(key: key);

  @override
  State<MultiSelectMultiColumnDropdownField<T>> createState() =>
      _MultiSelectMultiColumnDropdownFieldState<T>();
}

class _MultiSelectMultiColumnDropdownFieldState<T>
    extends State<MultiSelectMultiColumnDropdownField<T>> {
  static _MultiSelectMultiColumnDropdownFieldState? _currentOpenOverlay;
  final controller = Get.put(Controller());
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  String _searchQuery = '';
  T? _selectedItem;
  List<T> _selectedItems = []; // For multi-select
  bool _isOverlayOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
 print("allowMultSelects${widget.selectedValues}");
    if (widget.isMultiSelect) {
      _selectedItems = widget.selectedValues ?? [];
      _updateMultiSelectControllerText();
    } else {
      if (widget.selectedValue != null) {
        _selectedItem = widget.selectedValue;
        _controller.text = widget.displayText(widget.selectedValue as T);
      }
    }

    _controller.addListener(_handleSearch);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isOverlayOpen) {
        _hideOverlay();
      }
    });
  }

  void _handleSearch() {
    setState(() {
      _searchQuery = _controller.text;
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _showOverlay() {
    _currentOpenOverlay?._hideOverlay();

    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenHeight = MediaQuery.of(context).size.height;

    final dropdownHeight = widget.dropdownMaxHeight;
    final spaceBelow = screenHeight - offset.dy - size.height;
    final spaceAbove = offset.dy;

    final showAbove =
        spaceBelow < dropdownHeight && spaceAbove > dropdownHeight;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: widget.alignLeft ?? offset.dx,
        width: widget.dropdownWidth ?? size.width,
        top: showAbove
            ? offset.dy - dropdownHeight - 5
            : offset.dy + size.height + 5,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, showAbove ? -dropdownHeight - 5 : size.height + 5),
          child: Material(
            elevation: 4,
            child: _buildDropdownContent(),
          ),
        ),
      ),
    );

    Overlay.of(context, rootOverlay: true)!.insert(_overlayEntry!);
    _currentOpenOverlay = this;
    setState(() => _isOverlayOpen = true);

    ScrollableState? scrollableState = Scrollable.of(context);
    scrollableState?.position.addListener(_hideOverlay);
  }

  void _hideOverlay() {
    if (_isOverlayOpen) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      setState(() => _isOverlayOpen = false);

      ScrollableState? scrollableState = Scrollable.of(context);
      scrollableState?.position.removeListener(_hideOverlay);

      if (_currentOpenOverlay == this) {
        _currentOpenOverlay = null;
      }
    }
  }

  Widget _buildDropdownContent() {
    final List<T> sortedItems = List.from(widget.items);

    sortedItems.sort((a, b) {
      final aMatch = widget
          .searchValue(a)
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final bMatch = widget
          .searchValue(b)
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      if (aMatch == bMatch) return 0;
      return aMatch ? -1 : 1;
    });

    return Container(
      constraints: BoxConstraints(maxHeight: widget.dropdownMaxHeight),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 19),
            color: Colors.grey.shade200,
            child: Row(
              children: [
                if (widget.isMultiSelect)
                  const SizedBox(width: 40), // Space for checkbox
                ...widget.columnHeaders
                    .map(
                      (header) => Expanded(
                        child: Text(
                          header,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: sortedItems.length,
              itemBuilder: (context, index) {
                final item = sortedItems[index];
                return InkWell(
                  onTap: () => widget.isMultiSelect
                      ? _toggleItemSelection(item)
                      : _selectItem(item),
                  child: widget.isMultiSelect
                      ? _buildMultiSelectRow(item)
                      : widget.rowBuilder(item, _searchQuery),
                );
              },
            ),
          ),
          if (widget.isMultiSelect) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _confirmMultiSelection,
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMultiSelectRow(T item) {
    final isSelected = _selectedItems.contains(item);
    return Container(
      color: isSelected ? Colors.blue.withOpacity(0.1) : null,
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (value) => _toggleItemSelection(item),
          ),
          Expanded(
            child: widget.rowBuilder(item, _searchQuery),
          ),
        ],
      ),
    );
  }

  void _toggleItemSelection(T item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _confirmMultiSelection() {
    _updateMultiSelectControllerText();
    if (widget.onMultiChanged != null) {
      widget.onMultiChanged!(_selectedItems);
    }
    _hideOverlay();
    _focusNode.unfocus();
  }

 void _updateMultiSelectControllerText() {
  if (_selectedItems.isEmpty) {
    _controller.text = '';
    controller.cashAdvanceIds.text = '';
  } else {
    // Update display text
    _controller.text = _selectedItems
        .map((item) => widget.displayText(item))
        .join(', ');
        
    // Update semicolon-separated IDs for backend
    final ids = _selectedItems
        .map((item) => widget.displayText(item))
        .join(';');
    controller.cashAdvanceIds.text = ids;
    // controller.preloadedCashAdvReqIds = ids;
    
    print("Selected IDs: ${controller.cashAdvanceIds.text}");
  }
}
  void _selectItem(T item) {
    _controller.text = widget.displayText(item);
    _searchQuery = '';
    _selectedItem = item;
    widget.onChanged(item);
    _hideOverlay();
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleSearch);
    if (widget.controller == null) _controller.dispose();
    _focusNode.dispose();
    _hideOverlay();
    if (_currentOpenOverlay == this) {
      _currentOpenOverlay = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: FormField<List<T>>(
        initialValue: widget.isMultiSelect ? _selectedItems : null,
        validator: (value) {
          if (widget.isMultiSelect) {
            return widget.multiValidator?.call(_selectedItems);
          } else {
            return widget.validator?.call(_selectedItem);
          }
        },
        builder: (fieldState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled ?? true,
                decoration: widget.inputDecoration ??
                    InputDecoration(
                      labelText: widget.labelText,
                      filled: widget.backgroundColor != null,
                      fillColor: widget.backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(_isOverlayOpen
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down),
                        onPressed: () {
                          _isOverlayOpen ? _hideOverlay() : _showOverlay();
                        },
                      ),
                    ),
                onTap: () {
                  if (!_isOverlayOpen) _showOverlay();
                },
              ),
              if (fieldState.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12),
                  child: Text(
                    fieldState.errorText!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
