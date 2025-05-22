import 'package:flutter/material.dart';

/// A reusable multi-column dropdown styled like a FormField.
class MultiColumnDropdown<T> extends FormField<T> {
  final String labelText;
  final List<String> columnHeaders;
  final List<T> items;
  final Widget Function(T item) rowBuilder;
  final String Function(T selected) selectedDisplay;
  final double dropdownHeight;

  MultiColumnDropdown({
    Key? key,
    required this.labelText,
    required this.columnHeaders,
    required this.items,
    required this.rowBuilder,
    required ValueChanged<T?> onChanged,
    required this.selectedDisplay,
    T? initialValue,
    this.dropdownHeight = 300,
    FormFieldValidator<T>? validator,
  }) : super(
          key: key,
          initialValue: initialValue,
          validator: validator,
          builder: (FormFieldState<T> state) {
            return _MultiColumnDropdownField<T>(
              state: state,
              labelText: labelText,
              columnHeaders: columnHeaders,
              items: items,
              rowBuilder: rowBuilder,
              selectedDisplay: selectedDisplay,
              dropdownHeight: dropdownHeight,
              onChanged: onChanged,
            );
          },
        );
}

class _MultiColumnDropdownField<T> extends StatefulWidget {
  final FormFieldState<T> state;
  final String labelText;
  final List<String> columnHeaders;
  final List<T> items;
  final Widget Function(T item) rowBuilder;
  final void Function(T?) onChanged;
  final String Function(T selected) selectedDisplay;
  final double dropdownHeight;

  const _MultiColumnDropdownField({
    required this.state,
    required this.labelText,
    required this.columnHeaders,
    required this.items,
    required this.rowBuilder,
    required this.onChanged,
    required this.selectedDisplay,
    required this.dropdownHeight,
  });

  @override
  State<_MultiColumnDropdownField<T>> createState() => _MultiColumnDropdownFieldState<T>();
}

class _MultiColumnDropdownFieldState<T> extends State<_MultiColumnDropdownField<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlay;
  bool _isOpen = false;

  void _toggle() {
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlay = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 4,
        width: size.width,
        child: Material(
          elevation: 4,
          child: Container(
            constraints: BoxConstraints(maxHeight: widget.dropdownHeight),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Headers
                Container(
                  color: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    children: widget.columnHeaders
                        .map((h) => Expanded(child: Text(h, style: const TextStyle(fontWeight: FontWeight.bold))))
                        .toList(),
                  ),
                ),
                const Divider(height: 1),
                // Scrollable rows
                Expanded(
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
    _close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.state.value;
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        child: InputDecorator(
          isEmpty: selected == null,
          decoration: InputDecoration(
            labelText: widget.labelText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
            errorText: widget.state.errorText,
            suffixIcon: Icon(_isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down),
          ),
          child: Text(
            selected == null ? '' : widget.selectedDisplay(selected),
            style: TextStyle(color: selected == null ? Colors.grey : Colors.black),
          ),
        ),
      ),
    );
  }
}
