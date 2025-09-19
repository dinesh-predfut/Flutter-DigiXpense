import 'package:flutter/material.dart';

class SearchableMultiColumnDropdownField<T> extends StatefulWidget {
  final String? labelText;
  final List<String> columnHeaders;
  final List<T> items;
  final String Function(T)? searchValue;
  final void Function(T?) onChanged;
  final Widget Function(T, String searchQuery) rowBuilder;
  final String? Function(T?)? validator;
  final String Function(T) displayText;
  final T? selectedValue;
  final Color? backgroundColor;
  final InputDecoration? inputDecoration;
  final double dropdownMaxHeight;
  final double? dropdownWidth;
  final double? alignLeft;
  final bool? enabled;
  final TextEditingController? controller;

  const SearchableMultiColumnDropdownField({
    Key? key,
    required this.labelText,
    required this.columnHeaders,
    required this.items,
    this.searchValue,
    required this.onChanged,
    required this.rowBuilder,
    required this.displayText,
    this.validator,
    this.selectedValue,
    this.backgroundColor,
    this.inputDecoration,
    this.dropdownMaxHeight = 180,
    this.dropdownWidth,
    this.alignLeft,
    this.enabled,
    this.controller,
  }) : super(key: key);

  @override
  State<SearchableMultiColumnDropdownField<T>> createState() =>
      _SearchableMultiColumnDropdownFieldState<T>();
}

class _SearchableMultiColumnDropdownFieldState<T>
    extends State<SearchableMultiColumnDropdownField<T>> {
  static _SearchableMultiColumnDropdownFieldState? _currentOpenOverlay;

  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  String _searchQuery = '';
  T? _selectedItem;
  bool _isOverlayOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    if (widget.selectedValue != null) {
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

    if (widget.searchValue != null) {
      sortedItems.sort((a, b) {
        final aMatch = widget.searchValue!(a)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        final bMatch = widget.searchValue!(b)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        if (aMatch == bMatch) return 0;
        return aMatch ? -1 : 1;
      });
    }

    return Container(
      constraints: BoxConstraints(maxHeight: widget.dropdownMaxHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            color: Theme.of(context).primaryColor.withOpacity(0.08),
            child: Row(
              children: widget.columnHeaders
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
            ),
          ),
          const Divider(height: 0, thickness: 1),
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: sortedItems.length,
              itemBuilder: (context, index) {
                final item = sortedItems[index];
                return InkWell(
                  hoverColor: Colors.blue.withOpacity(0.08),
                  onTap: () => _selectItem(item),
                  child: Container(
                    height: 48,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    color: _selectedItem == item
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    child: widget.rowBuilder(item, _searchQuery),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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
      child: FormField<T>(
        initialValue: _selectedItem,
        validator: widget.validator,
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
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}