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
  final bool? readOnly;
  final bool? enabled;
  final TextEditingController? controller;
  final bool? forceShowAbove; // nullable: true=above, false=below, null=auto

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
    this.readOnly,
    this.forceShowAbove,
  }) : super(key: key);

  @override
  State<SearchableMultiColumnDropdownField<T>> createState() =>
      _SearchableMultiColumnDropdownFieldState<T>();
}

class _SearchableMultiColumnDropdownFieldState<T>
    extends State<SearchableMultiColumnDropdownField<T>> {
  static _SearchableMultiColumnDropdownFieldState? _currentOpenOverlay;

  // Height of a single row in the list (used for scroll-to-selected).
  static const double _rowHeight = 48.0;
  // Approx header + divider height subtracted from the body.
  static const double _headerHeight = 33.0;

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

  // FIX: keep references so we can reliably clean them up later.
  _KeyboardObserver? _keyboardObserver;
  ScrollableState? _scrollableState;

  // FIX: list actually shown in the dropdown (filtered + sorted), shared
  // between the builder and the scroll-to-selected logic.
  List<T> _visibleItems = const [];

  // FIX: guards so the controller listener doesn't fight programmatic edits,
  // and so we never call setState after dispose.
  bool _suppressSearch = false;
  bool _disposed = false;

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

    _visibleItems = _computeVisibleItems();

    _controller.addListener(_handleSearch);

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isOverlayOpen) {
        _hideOverlay();
      }
    });
  }

  void _safeSetState(VoidCallback fn) {
    if (_disposed || !mounted) {
      fn();
      return;
    }
    setState(fn);
  }

  // The query to actually filter by. When a value is selected, the controller
  // holds its full display text; treat that as "no query" so the full list
  // shows instead of filtering everything away.
  String _effectiveQuery() {
    if (_selectedItem != null &&
        _searchQuery == widget.displayText(_selectedItem as T)) {
      return '';
    }
    return _searchQuery;
  }

  // FIX: real filtering (not just sorting), with starts-with results first.
  List<T> _computeVisibleItems() {
    final all = List<T>.from(widget.items);
    final searchValue = widget.searchValue;
    final q = _effectiveQuery().trim().toLowerCase();

    if (q.isEmpty || searchValue == null) return all;

    final filtered =
        all.where((e) => searchValue(e).toLowerCase().contains(q)).toList();

    filtered.sort((a, b) {
      final aText = searchValue(a).toLowerCase();
      final bText = searchValue(b).toLowerCase();
      final aStarts = aText.startsWith(q);
      final bStarts = bText.startsWith(q);
      if (aStarts && !bStarts) return -1;
      if (!aStarts && bStarts) return 1;
      return aText.compareTo(bText);
    });

    return filtered;
  }

  void _handleSearch() {
    if (_suppressSearch) return; // ignore programmatic text changes

    _searchQuery = _controller.text;

    if (_controller.text.isEmpty && _selectedItem != null) {
      _selectedItem = null;
      widget.onChanged(null);
    }

    _visibleItems = _computeVisibleItems();
    _safeSetState(() {});
    _overlayEntry?.markNeedsBuild();
  }

  void _showOverlay() {
    _currentOpenOverlay?._hideOverlay();

    _visibleItems = _computeVisibleItems();

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

          // forceShowAbove: true=always above, false=always below, null=auto
          showAbove = widget.forceShowAbove ??
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
    _safeSetState(() => _isOverlayOpen = true);

    // FIX: store the observer so we can remove it in _hideOverlay.
    _keyboardObserver = _KeyboardObserver(_overlayEntry!);
    WidgetsBinding.instance.addObserver(_keyboardObserver!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedItem != null) {
        // FIX: index into the list that is actually rendered.
        final index = _visibleItems.indexOf(_selectedItem as T);
        if (index >= 0 && _scrollController.hasClients) {
          final position = index * _rowHeight;
          _scrollController.jumpTo(
            position.clamp(0.0, _scrollController.position.maxScrollExtent),
          );
        }
      }
    });

    // FIX: maybeOf so we don't assert when not inside a Scrollable, and keep
    // the same instance for add/remove.
    _scrollableState = Scrollable.maybeOf(context);
    _scrollableState?.position.addListener(_hideOverlay);
  }

  void _hideOverlay() {
    if (!_isOverlayOpen) return;

    _overlayEntry?.remove();
    _overlayEntry = null;

    if (_keyboardObserver != null) {
      WidgetsBinding.instance.removeObserver(_keyboardObserver!);
      _keyboardObserver = null;
    }

    _scrollableState?.position.removeListener(_hideOverlay);
    _scrollableState = null;

    if (_currentOpenOverlay == this) {
      _currentOpenOverlay = null;
    }

    _safeSetState(() => _isOverlayOpen = false);
  }

  Widget _buildDropdownContent({required bool showAbove}) {
    final items = _visibleItems;

    // Header — corners flip based on showAbove
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

    // Body — SAME fixed height for both empty and list states
    final body = SizedBox(
      height: widget.dropdownMaxHeight - _headerHeight,
      child: items.isEmpty
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
              shrinkWrap: false,
              physics: const ClampingScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                Color? rowColor;
                if (_selectedItem != null &&
                    widget.displayText(_selectedItem as T) ==
                        widget.displayText(item)) {
                  rowColor =
                      Theme.of(context).highlightColor.withOpacity(0.5);
                }

                return InkWell(
                  hoverColor: Colors.blue.withOpacity(0.08),
                  onTap: () => _selectItem(item),
                  child: Container(
                    height: _rowHeight,
                    alignment: Alignment.centerLeft,
                    color: rowColor,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: widget.rowBuilder(item, _effectiveQuery()),
                    ),
                  ),
                );
              },
            ),
    );

    return Container(
      height: widget.dropdownMaxHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [header, const Divider(height: 0, thickness: 1), body],
      ),
    );
  }

  void _selectItem(T item) {
    // FIX: suppress the listener so setting the text doesn't re-trigger
    // _handleSearch (which would fire an extra setState / treat the display
    // text as a query).
    _suppressSearch = true;
    _controller.text = widget.displayText(item);
    _suppressSearch = false;

    _searchQuery = '';
    _selectedItem = item;
    _visibleItems = _computeVisibleItems();
    _safeSetState(() {});

    widget.onChanged(item);
    _hideOverlay();
    _focusNode.unfocus();
  }

  @override
  void didUpdateWidget(covariant SearchableMultiColumnDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep the visible list in sync if the parent swaps the items list.
    if (!identical(oldWidget.items, widget.items)) {
      _visibleItems = _computeVisibleItems();
      _overlayEntry?.markNeedsBuild();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _controller.removeListener(_handleSearch);
    _hideOverlay();
    if (widget.controller == null) _controller.dispose();
    _focusNode.dispose();
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
                  readOnly: widget.readOnly ?? false,
                  decoration: widget.inputDecoration ??
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

// Observes keyboard metric changes and repositions the overlay.
// FIX: does NOT remove itself — the field owns its lifecycle and removes it
// in _hideOverlay, so repositioning keeps working on every keyboard change.
class _KeyboardObserver extends WidgetsBindingObserver {
  final OverlayEntry entry;

  _KeyboardObserver(this.entry);

  @override
  void didChangeMetrics() {
    entry.markNeedsBuild();
  }
}