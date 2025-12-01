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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();

    // Initialize selected item and controller text from initial value
    if (widget.selectedValue != null) {
      _selectedItem = widget.selectedValue;

      // Only set text if controller is not externally controlled
      if (widget.controller == null) {
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

    // If the user clears the text, clear the selected item
    if (_controller.text.isEmpty && _selectedItem != null) {
      setState(() {
        _selectedItem = null;
      });
      widget.onChanged(null);
    }

    _overlayEntry?.markNeedsBuild();
  }

  void _showOverlay() {
    // Hide any other open dropdown before showing this one
    _currentOpenOverlay?._hideOverlay();

    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenHeight = MediaQuery.of(context).size.height;

    final dropdownHeight = widget.dropdownMaxHeight;
    final spaceBelow = screenHeight - offset.dy - size.height;
    final spaceAbove = offset.dy;

    // Determine if the dropdown should show above or below the field
    final showAbove =
        spaceBelow < dropdownHeight && spaceAbove > dropdownHeight;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Transparent barrier to detect taps outside the dropdown
          Positioned.fill(
            child: GestureDetector(
              onTap: _hideOverlay,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),

          // Positioned dropdown
          Positioned(
            left: widget.alignLeft ?? offset.dx,
            width: widget.dropdownWidth ?? size.width,
            top: showAbove
                ? offset.dy - dropdownHeight - 5
                : offset.dy + size.height + 5,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(
                0,
                showAbove ? -dropdownHeight - 5 : size.height + 5,
              ),
              child: Material(elevation: 4, child: _buildDropdownContent()),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context, rootOverlay: true)!.insert(_overlayEntry!);
    _currentOpenOverlay = this;
    setState(() => _isOverlayOpen = true);

    // Auto-scroll to selected item after opening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedItem != null) {
        final index = widget.items.indexOf(_selectedItem as T);
        if (index >= 0 && index < widget.items.length) {
          final position = index * 48.0; // Approx height per row
          _scrollController.jumpTo(
            position.clamp(0.0, _scrollController.position.maxScrollExtent),
          );
        }
      }
    });

    // Hide overlay if scroll position changes
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
    List<T> sortedItems = List.from(widget.items);

    // Sort based on search query
    if (widget.searchValue != null && _searchQuery.isNotEmpty) {
      sortedItems.sort((a, b) {
        final aMatch = widget.searchValue!(a).toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
        final bMatch = widget.searchValue!(b).toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );

        final aStartsWith = widget.searchValue!(a).toLowerCase().startsWith(
          _searchQuery.toLowerCase(),
        );
        final bStartsWith = widget.searchValue!(b).toLowerCase().startsWith(
          _searchQuery.toLowerCase(),
        );

        if (aStartsWith && !bStartsWith) return -1;
        if (!aStartsWith && bStartsWith) return 1;
        if (aMatch && !bMatch) return -1;
        if (!aMatch && bMatch) return 1;
        return 0;
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
          // Header Row
         Container(
  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
  color: Theme.of(context).primaryColor,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: widget.columnHeaders
        .map(
          (header) => Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                header,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 8,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        )
        .toList(),
  ),
),

          const Divider(height: 0, thickness: 1),

          // List Items
          Flexible(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: sortedItems.length,
              itemBuilder: (context, index) {
                final item = sortedItems[index];

                bool isSearchMatch = false;
                if (_searchQuery.isNotEmpty && widget.searchValue != null) {
                  isSearchMatch = widget.searchValue!(item)
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase());
                }

                // Highlight selected or matching row
                Color? rowColor;
                if (_selectedItem != null && _selectedItem == item) {
                  rowColor = Theme.of(context).highlightColor.withOpacity(0.5);
                } else if (isSearchMatch) {
                  rowColor = Theme.of(context).focusColor.withOpacity(0.1);
                } else {
                  rowColor = Colors.transparent;
                }

                return InkWell(
                  hoverColor: Colors.blue.withOpacity(0.08),
                  onTap: () => _selectItem(item),
                  child: Container(
                    height: 48,
                    alignment: Alignment.centerLeft,
                    // padding: const EdgeInsets.symmetric(horizontal: 12),
                    color: rowColor,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: widget.rowBuilder(item, _searchQuery),
                    ),
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

    setState(() {
      _selectedItem = item;
    });

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
    _scrollController.dispose();
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
                decoration:
                    widget.inputDecoration ??
                    InputDecoration(
                      labelText: widget.labelText,
                      filled: widget.backgroundColor != null,
                      fillColor: widget.backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isOverlayOpen
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                        ),
                        onPressed: () {
                          if (_isOverlayOpen) {
                            _hideOverlay();
                          } else {
                            _focusNode.requestFocus();
                            _showOverlay();
                          }
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
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
