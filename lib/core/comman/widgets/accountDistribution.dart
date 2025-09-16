import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../l10n/app_localizations.dart'; // import the localization manager

class AccountingDistributionWidget extends StatefulWidget {
  final int? index;
  final List<AccountingSplit> splits;
  final double lineAmount;
  final void Function(int index, AccountingSplit updatedSplit)? onChanged;
  final void Function(List<AccountingDistribution>)? onDistributionChanged;

  const AccountingDistributionWidget({
    super.key,
    this.index,
    required this.splits,
    required this.lineAmount,
    this.onChanged,
    this.onDistributionChanged,
  });

  @override
  State<AccountingDistributionWidget> createState() =>
      _AccountingDistributionWidgetState();
}

class _AccountingDistributionWidgetState
    extends State<AccountingDistributionWidget> {
  final controller = Get.put(Controller());
  List<DimensionHierarchy> dimensionList = [];
  List<DimensionValue> dimensionValueList = [];
  Map<int, bool> isPanelExpandedMap = {};
  Map<int, Map<String, String?>> splitSelectedDimensionValues = {};
  OverlayEntry? _overlayEntry;
  int? _openDropdownIndex;
  int? _openPanelIndex;

  // 🔷 Add loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadDimensionData();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _loadDimensionData() async {
    try {
      final dimensions = await controller.fetchDimensionHierarchies();
      final values = await controller.fetchDimensionValues();
      setState(() {
        dimensionList = dimensions;
        dimensionValueList = values;
        for (int i = 0; i < widget.splits.length; i++) {
          final paidFor = widget.splits[i].paidFor ?? '';
          if (paidFor.isNotEmpty) {
            final parts = paidFor.split(",");
            final map = <String, String?>{};
            for (int j = 0; j < parts.length && j < dimensionList.length; j++) {
              map[dimensionList[j].dimensionId] = parts[j];
            }
            splitSelectedDimensionValues[i] = map;
          } else {
            splitSelectedDimensionValues[i] = {};
          }
          isPanelExpandedMap[i] = false;
        }
      });
    } catch (e) {
      debugPrint("Error loading dimension data: $e");
    }
  }

  List<DimensionValue> _getFilteredValues(String dimensionId) {
    return dimensionValueList
        .where((val) => val.dimensionId == dimensionId)
        .toList();
  }

  void _showOverlay({
    required BuildContext context,
    required RenderBox buttonBox,
    required String dimensionId,
    required String? currentValue,
    required void Function(String?) onSelect,
  }) {
    _overlayEntry?.remove();
    _overlayEntry = null;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset buttonTopLeft = buttonBox.localToGlobal(Offset.zero);
    final Size buttonSize = buttonBox.size;
    final items = _getFilteredValues(dimensionId);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: buttonTopLeft.dy + buttonSize.height,
        left: buttonTopLeft.dx,
        width: buttonSize.width,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 140),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (ctx, idx) {
                final item = items[idx];
                final displayText = '${item.valueName} (${item.dimensionValueId})';
                final isSelected = item.dimensionValueId == currentValue;
                return GestureDetector(
                  onTap: () {
                    onSelect(item.dimensionValueId);
                    _overlayEntry?.remove();
                    _overlayEntry = null;
                    setState(() {
                      _openDropdownIndex = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.withOpacity(0.1) : null,
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Text(
                      displayText,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    Overlay.of(context)?.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _openEditPanel(int index) {
    setState(() {
      if (_openPanelIndex != null && _openPanelIndex != index) {
        isPanelExpandedMap[_openPanelIndex!] = false;
      }
      isPanelExpandedMap[index] = true;
      _openPanelIndex = index;
    });
  }

  void _closeEditPanel(int index) {
    setState(() {
      isPanelExpandedMap[index] = false;
      if (_openPanelIndex == index) _openPanelIndex = null;
    });
  }

  void _addSplit() {
    final newIndex = widget.splits.length;
    setState(() {
      widget.splits.add(AccountingSplit(percentage: 100.0));
      isPanelExpandedMap[newIndex] = false;
      splitSelectedDimensionValues[newIndex] = {};
    });
  }

  void _removeSplit(int index) {
    setState(() {
      widget.splits.removeAt(index);
      isPanelExpandedMap.remove(index);
      splitSelectedDimensionValues.remove(index);
      if (_openPanelIndex == index) _openPanelIndex = null;
      if (_openDropdownIndex == index) _openDropdownIndex = null;
    });
    _hideOverlay();
  }

  double get _totalPercentage =>
      widget.splits.fold(0.0, (sum, item) => sum + (item.percentage ?? 0.0));

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!; // 🔹 localization shortcut

    return Column(
      children: [
        const SizedBox(height: 16),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else
          ...widget.splits.asMap().entries.map((entry) {
            final index = entry.key;
            final split = entry.value;
            final calculatedAmount =
                widget.lineAmount * ((split.percentage ?? 0.0) / 100);
            split.amount = calculatedAmount;
            final selectedValues = splitSelectedDimensionValues[index] ?? {};
            final selectedValueString =
                selectedValues.values.whereType<String>().join(',') ?? '';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (isPanelExpandedMap[index] == true) {
                          _closeEditPanel(index);
                        } else {
                          _openEditPanel(index);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  selectedValueString.isNotEmpty
                                      ? selectedValueString
                                      : strings.selectDimensions,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            Icon(
                              isPanelExpandedMap[index] == true
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 20,
                              color: Colors.grey[700],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isPanelExpandedMap[index] == true) ...[
                      const SizedBox(height: 14),
                      ...dimensionList.map((dimension) {
                        final values = _getFilteredValues(dimension.dimensionId);
                        final currentVal = selectedValues[dimension.dimensionId];
                        String displayText = "${strings.selectDimensions} ${dimension.dimensionName}";
                        if (currentVal != null) {
                          final item = values.firstWhereOrNull(
                              (v) => v.dimensionValueId == currentVal);
                          if (item != null) {
                            displayText =
                                '${item.valueName} (${item.dimensionValueId})';
                          }
                        }

                        return StatefulBuilder(
                          builder: (context, innerSetState) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dimension.dimensionName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    return SizedBox(
                                      height: 40,
                                      child: TextFormField(
                                        readOnly: true,
                                        onTap: () {
                                          final RenderBox? renderBox = context
                                              .findRenderObject() as RenderBox?;
                                          if (renderBox == null) return;

                                          if (_openDropdownIndex == index) {
                                            _hideOverlay();
                                            setState(() {
                                              _openDropdownIndex = null;
                                            });
                                          } else {
                                            if (_openDropdownIndex != null &&
                                                _openDropdownIndex != index) {
                                              _hideOverlay();
                                            }
                                            _openDropdownIndex = index;
                                            _showOverlay(
                                              context: context,
                                              buttonBox: renderBox,
                                              dimensionId: dimension.dimensionId,
                                              currentValue: currentVal,
                                              onSelect: (value) {
                                                innerSetState(() {
                                                  selectedValues[dimension.dimensionId] =
                                                      value;
                                                });
                                                setState(() {
                                                  splitSelectedDimensionValues[index] =
                                                      Map.from(selectedValues);
                                                  _openDropdownIndex = null;
                                                });
                                              },
                                            );
                                          }
                                        },
                                        decoration: InputDecoration(
                                          hintText: strings.selectDimensions,
                                          hintStyle: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                          filled: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(horizontal: 10),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(6),
                                            borderSide:
                                                BorderSide(color: Colors.grey.shade400),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(6),
                                            borderSide:
                                                BorderSide(color: Colors.grey.shade400),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(6),
                                            borderSide: BorderSide(
                                                color: AppColors.gradientEnd, width: 2),
                                          ),
                                          isDense: true,
                                          suffixIcon: GestureDetector(
                                            onTap: () {
                                              if (_openDropdownIndex == index) {
                                                _hideOverlay();
                                                setState(() {
                                                  _openDropdownIndex = null;
                                                });
                                              } else {
                                                final renderBox = context
                                                    .findRenderObject() as RenderBox?;
                                                if (renderBox == null) return;
                                                if (_openDropdownIndex != null &&
                                                    _openDropdownIndex != index) {
                                                  _hideOverlay();
                                                }
                                                _openDropdownIndex = index;
                                                _showOverlay(
                                                  context: context,
                                                  buttonBox: renderBox,
                                                  dimensionId: dimension.dimensionId,
                                                  currentValue: currentVal,
                                                  onSelect: (value) {
                                                    innerSetState(() {
                                                      selectedValues[dimension.dimensionId] =
                                                          value;
                                                    });
                                                    setState(() {
                                                      splitSelectedDimensionValues[index] =
                                                          Map.from(selectedValues);
                                                      _openDropdownIndex = null;
                                                    });
                                                  },
                                                );
                                              }
                                            },
                                            child: Icon(
                                              _openDropdownIndex == index
                                                  ? Icons.arrow_drop_up
                                                  : Icons.arrow_drop_down,
                                              size: 18,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                        style: const TextStyle(fontSize: 12),
                                        controller: TextEditingController(text: displayText)
                                          ..selection = TextSelection.collapsed(
                                              offset: displayText.length),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                              ],
                            );
                          },
                        );
                      }).toList(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              final savedValues =
                                  splitSelectedDimensionValues[index] ?? {};
                              final dimensionIds =
                                  savedValues.values.whereType<String>().join(',');
                              setState(() {
                                widget.splits[index] =
                                    split.copyWith(paidFor: dimensionIds);
                                _closeEditPanel(index);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gradientEnd,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                            ),
                            child: Text(
                              strings.save,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => _closeEditPanel(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                            ),
                            child: Text(
                              strings.cancel,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: (split.percentage ?? 0.0).toStringAsFixed(2),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: strings.percentage,
                        labelStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: AppColors.gradientEnd, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 13),
                      onChanged: (value) {
                        final parsed = double.tryParse(value) ?? 0.0;
                        final updated = split.copyWith(
                          percentage: parsed,
                          amount: widget.lineAmount * (parsed / 100),
                        );
                        setState(() {
                          widget.splits[index] = updated;
                        });
                        widget.onChanged?.call(index, updated);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${strings.amount}: ${calculatedAmount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "${strings.report}: ${calculatedAmount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => _removeSplit(index),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          }).toList(),
        if (!_isLoading && _totalPercentage != 100)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              strings.totalPercentageMustBe100(_totalPercentage),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        const SizedBox(height: 16),
        if (!_isLoading)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _addSplit,
                icon: const Icon(Icons.add, size: 16),
                label: Text(strings.addSplit, style: const TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(width: 14),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
                child: Text(strings.cancel, style: const TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 14),
              ElevatedButton(
                onPressed: () {
                  if (_totalPercentage != 100) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          strings.totalPercentageMustBe100(_totalPercentage),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  final distributions = widget.splits.map((split) {
                    final amount = split.amount ?? 0.0;
                    return AccountingDistribution(
                      transAmount: double.parse(amount.toStringAsFixed(2)),
                      reportAmount: double.parse(amount.toStringAsFixed(2)),
                      allocationFactor: split.percentage ?? 0.0,
                      dimensionValueId: split.paidFor ?? '',
                    );
                  }).toList();
                  widget.onDistributionChanged?.call(distributions);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gradientEnd,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
                child: Text(
                  strings.save,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }
}
