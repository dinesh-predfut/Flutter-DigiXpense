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
  final bool? forceShowAbove; // ✅ nullable: true=above, false=below, null=auto

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
    this.forceShowAbove, // ✅ optional, not required
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

  Size _fieldSize = Size.zero;
  final GlobalKey _fieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();

    if (widget.selectedValue != null) {
      _selectedItem = widget.selectedValue;
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

    if (_controller.text.isEmpty && _selectedItem != null) {
      setState(() {
        _selectedItem = null;
      });
      widget.onChanged(null);
    }

    _overlayEntry?.markNeedsBuild();
  }

  void _showOverlay() {
    _currentOpenOverlay?._hideOverlay();

    final renderBox = context.findRenderObject() as RenderBox;
    _fieldSize = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        final RenderBox? box =
            _fieldKey.currentContext?.findRenderObject() as RenderBox?;

        final keyboardHeight = MediaQueryData.fromView(
          View.of(overlayContext),
        ).viewInsets.bottom;
        final screenHeight = MediaQueryData.fromView(
          View.of(overlayContext),
        ).size.height;

        double top = 0;
        double left = widget.alignLeft ?? 0;
        double fieldWidth = widget.dropdownWidth ?? _fieldSize.width;
        bool showAbove = false;

        final fieldGap = keyboardHeight > 0 ? 12.0 : 5.0;

        if (box != null && box.hasSize) {
          final globalOffset = box.localToGlobal(Offset.zero);
          final fieldBottom = globalOffset.dy + box.size.height;
          final spaceBelow = screenHeight - keyboardHeight - fieldBottom;
          final spaceAbove = globalOffset.dy;
          final dropdownHeight = widget.dropdownMaxHeight;

          fieldWidth = widget.dropdownWidth ?? box.size.width;

          // ✅ forceShowAbove: true=always above, false=always below, null=auto
          showAbove =
              widget.forceShowAbove ??
              (spaceBelow < dropdownHeight && spaceAbove > spaceBelow);

          if (showAbove) {
            top = globalOffset.dy - dropdownHeight - fieldGap;
          } else {
            double naturalTop = fieldBottom + fieldGap;
            double naturalBottom = naturalTop + dropdownHeight;
            double keyboardTop = screenHeight - keyboardHeight;

            if (naturalBottom > keyboardTop && keyboardHeight > 0) {
              top = keyboardTop - dropdownHeight - 8;
            } else {
              top = naturalTop;
            }
          }

          left = globalOffset.dx + (widget.alignLeft ?? 0);
        }

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _hideOverlay,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox(),
              ),
            ),
            Positioned(
              top: top,
              left: left,
              width: fieldWidth,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(4),
                child: _buildDropdownContent(showAbove: showAbove),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    _currentOpenOverlay = this;
    setState(() => _isOverlayOpen = true);

    WidgetsBinding.instance.addObserver(_KeyboardObserver(_overlayEntry!));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedItem != null) {
        final index = widget.items.indexOf(_selectedItem as T);
        if (index >= 0 &&
            _scrollController.hasClients &&
            index < widget.items.length) {
          final position = index * 48.0;
          _scrollController.jumpTo(
            position.clamp(0.0, _scrollController.position.maxScrollExtent),
          );
        }
      }
    });

    ScrollableState? scrollableState = Scrollable.of(context);
    scrollableState?.position.addListener(_hideOverlay);
  }

  _KeyboardObserver? _keyboardObserver;

  void _hideOverlay() {
    if (_isOverlayOpen) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      setState(() => _isOverlayOpen = false);

      if (_keyboardObserver != null) {
        WidgetsBinding.instance.removeObserver(_keyboardObserver!);
        _keyboardObserver = null;
      }

      ScrollableState? scrollableState = Scrollable.of(context);
      scrollableState?.position.removeListener(_hideOverlay);

      if (_currentOpenOverlay == this) {
        _currentOpenOverlay = null;
      }
    }
  }

  Widget _buildDropdownContent({required bool showAbove}) {
    List<T> sortedItems = List.from(widget.items);

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

    // ✅ Header — corners flip based on showAbove
    final header = Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: showAbove ? Radius.zero : const Radius.circular(4),
          topRight: showAbove ? Radius.zero : const Radius.circular(4),
          bottomLeft: showAbove ? const Radius.circular(4) : Radius.zero,
          bottomRight: showAbove ? const Radius.circular(4) : Radius.zero,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: widget.columnHeaders
            .map(
              (h) => Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    h,
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
    );

    // ✅ Body — SAME fixed height for both empty and list states
    final body = SizedBox(
      height: widget.dropdownMaxHeight - 33, // 33 = header height (approx)
      child: sortedItems.isEmpty
          ? Container(
              color: Theme.of(context).cardColor,
              alignment: Alignment.center,
              child: const Text(
                'No data available',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              shrinkWrap:
                  false, // ✅ false so it fills the fixed SizedBox height
              physics: const ClampingScrollPhysics(),
              itemCount: sortedItems.length,
              itemBuilder: (context, index) {
                final item = sortedItems[index];

                Color? rowColor;
                if (_selectedItem != null &&
                    widget.displayText(_selectedItem as T) ==
                        widget.displayText(item)) {
                  rowColor = Theme.of(context).highlightColor.withOpacity(0.5);
                }

                return InkWell(
                  hoverColor: Colors.blue.withOpacity(0.08),
                  onTap: () => _selectItem(item),
                  child: Container(
                    height: 48,
                    alignment: Alignment.centerLeft,
                    color: rowColor,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: widget.rowBuilder(item, _searchQuery),
                    ),
                  ),
                );
              },
            ),
    );

    return Container(
      // ✅ Fixed total height always — no jumping between empty and filled
      height: widget.dropdownMaxHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        // ✅ Header always on top, never reorder
        children: [header, const Divider(height: 0, thickness: 1), body],
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
      child: KeyedSubtree(
        key: _fieldKey,
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
      ),
    );
  }
}

// ✅ Observes keyboard metric changes and forces overlay to reposition
class _KeyboardObserver extends WidgetsBindingObserver {
  final OverlayEntry entry;

  _KeyboardObserver(this.entry);

  @override
  void didChangeMetrics() {
    entry.markNeedsBuild();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.removeObserver(this);
    });
  }
}
