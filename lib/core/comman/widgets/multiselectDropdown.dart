import 'package:digi_xpense/data/service.dart' show Controller;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../l10n/app_localizations.dart';

class MultiSelectMultiColumnDropdownField<T> extends StatefulWidget {
  final String? labelText;
  final List<String> columnHeaders;
  final List<T> items;
  final String Function(T) searchValue;
  final void Function(T?) onChanged;
  final void Function(List<T>)? onMultiChanged;
  final Widget Function(T, String searchQuery) rowBuilder;
  final String? Function(T?)? validator;
  final String? Function(List<T>)? multiValidator;
  final String Function(T) displayText;
  final T? selectedValue;
  final List<T>? selectedValues;
  final Color? backgroundColor;
  final InputDecoration? inputDecoration;
  final double dropdownMaxHeight;
  final double? dropdownWidth;
  final double? alignLeft;
  final bool? enabled;
  final TextEditingController? controller;
  final bool isMultiSelect;

  /// ✅ Optional header for Select All or custom widget
  final Widget Function()? headerBuilder;

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
    required this.isMultiSelect,
    this.headerBuilder,
  }) : super(key: key);

  @override
  State<MultiSelectMultiColumnDropdownField<T>> createState() =>
      _MultiSelectMultiColumnDropdownFieldState<T>();
}

class _MultiSelectMultiColumnDropdownFieldState<T>
    extends State<MultiSelectMultiColumnDropdownField<T>> {
  static _MultiSelectMultiColumnDropdownFieldState? _currentOpenOverlay;
  final controller = Get.put(Controller()); // Replace with your Controller
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  String _searchQuery = '';
  T? _selectedItem;
  List<T> _selectedItems = [];
  bool _isOverlayOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();

    if (widget.isMultiSelect) {
      _selectedItems = List<T>.from(widget.selectedValues ?? []);
      _updateMultiSelectControllerText();
    } else if (widget.selectedValue != null) {
      _selectedItem = widget.selectedValue;
      _controller.text = widget.displayText(widget.selectedValue as T);
    }

    _controller.addListener(_handleSearch);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isOverlayOpen) {
        _hideOverlay();
      }
    });
  }

  @override
  void didUpdateWidget(
      covariant MultiSelectMultiColumnDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMultiSelect) {
      _selectedItems = List<T>.from(widget.selectedValues ?? []);
      _updateMultiSelectControllerText();
    } else if (widget.selectedValue != _selectedItem) {
      _selectedItem = widget.selectedValue;
      if (_selectedItem != null) {
        _controller.text = widget.displayText(_selectedItem as T);
      }
    }
  }

  void _handleSearch() {
    setState(() {
      _searchQuery = _controller.text;
    });

    // 🔹 Reset selection if user clears the field
    if (_controller.text.isEmpty) {
      if (widget.isMultiSelect && _selectedItems.isNotEmpty) {
        setState(() {
          _selectedItems.clear();
        });
        widget.onMultiChanged?.call([]);
        controller.cashAdvanceIds.text = '';
      } else if (!widget.isMultiSelect && _selectedItem != null) {
        setState(() {
          _selectedItem = null;
        });
        widget.onChanged(null);
      }
    }
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
  }

  void _hideOverlay() {
    if (_isOverlayOpen) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      setState(() => _isOverlayOpen = false);

      if (_currentOpenOverlay == this) {
        _currentOpenOverlay = null;
      }
    }
  }

  bool get _isAllSelected =>
      widget.items.isNotEmpty && _selectedItems.length == widget.items.length;

  void _toggleSelectAll() {
    setState(() {
      if (_isAllSelected) {
        _selectedItems.clear();
      } else {
        _selectedItems = List<T>.from(widget.items);
      }
    });
    _overlayEntry?.markNeedsBuild();
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
      ),
      child: Column(
        children: [
          /// ✅ Optional custom header (Select All)
          if (widget.isMultiSelect && widget.headerBuilder != null)
            widget.headerBuilder!(),

          /// 🔹 Column headers
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: Row(
              children: [
                if (widget.isMultiSelect) const SizedBox(width: 40),
                ...widget.columnHeaders.map(
                  (header) => Expanded(
                    child: Text(
                      header,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
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
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _confirmMultiSelection,
                    child: Text(AppLocalizations.of(context)!.confirm),
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
          Expanded(child: widget.rowBuilder(item, _searchQuery)),
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
    widget.onMultiChanged?.call(_selectedItems);
    _hideOverlay();
    _focusNode.unfocus();
  }

  void _updateMultiSelectControllerText() {
    if (_selectedItems.isEmpty) {
      _controller.text = '';
      controller.cashAdvanceIds.text = '';
    } else {
      _controller.text =
          _selectedItems.map((item) => widget.displayText(item)).join(', ');
      final ids =
          _selectedItems.map((item) => widget.displayText(item)).join(';');
      controller.cashAdvanceIds.text = ids;
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
    if (_currentOpenOverlay == this) _currentOpenOverlay = null;
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
