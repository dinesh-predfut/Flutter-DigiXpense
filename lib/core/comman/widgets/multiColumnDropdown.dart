import 'package:flutter/material.dart';

class MultiColumnDropdownField<T> extends StatefulWidget {
  final FormFieldState<T> state;
  final String labelText;
  final List<String> columnHeaders;
  final List<T> items;
  final Widget Function(T item) rowBuilder;
  final void Function(T?) onChanged;
  final String Function(T selected) selectedDisplay;
  final double dropdownHeight;

  const MultiColumnDropdownField({
    Key? key,
    required this.state,
    required this.labelText,
    required this.columnHeaders,
    required this.items,
    required this.rowBuilder,
    required this.onChanged,
    required this.selectedDisplay,
    required this.dropdownHeight,
  }) : super(key: key);

  @override
  State<MultiColumnDropdownField<T>> createState() =>
      MultiColumnDropdownFieldState<T>();
}

class MultiColumnDropdownFieldState<T>
    extends State<MultiColumnDropdownField<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlay;
  bool _isOpen = false;
  late FocusNode _focusNode;
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
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isOpen) {
        _close();
      }
    });
  }

  void _toggle() {
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    FocusScope.of(context).requestFocus(_focusNode);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlay = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Stack(
          children: [
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 4),
              child: Material(
                elevation: 4,
                child: Container(
                  constraints: BoxConstraints(maxHeight: widget.dropdownHeight),
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        color: Colors.grey[200],
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: Row(
                          children: widget.columnHeaders
                              .map((h) => Expanded(
                                  child: Text(h,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold))))
                              .toList(),
                        ),
                      ),
                      const Divider(height: 1),
                      Flexible(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: widget.items.length,
                          itemBuilder: (_, i) {
                            final item = widget.items[i];
                            return InkWell(
                              onTap: () {
                                widget.state.didChange(item);
                                widget.onChanged(item);
                                _close();
                              },
                              child: widget.rowBuilder(item),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context)!.insert(_overlay!);
    setState(() => _isOpen = true);
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
    setState(() => _isOpen = false);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.state.value;
    return CompositedTransformTarget(
      link: _layerLink,
      child: Focus(
        focusNode: _focusNode,
        child: GestureDetector(
          onTap: _toggle,
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
              style: TextStyle(
                  color: selected == null ? Colors.grey : Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
