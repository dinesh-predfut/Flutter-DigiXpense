import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

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
      // 🔷 Stop loading after data is loaded
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
                    // 🔷 Close dropdown and reset index
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
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.blue : Colors.black87,
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
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
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
      widget.splits.add( AccountingSplit(percentage: 100.0));
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
    return Column(
      children: [
        const SizedBox(height: 16),

        // 🔷 Show loader instead of splits while loading
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
              color: const Color.fromARGB(234, 214, 224, 247),
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
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  selectedValueString.isNotEmpty
                                      ? selectedValueString
                                      : "Select Dimensions",
                                  style: TextStyle(
                                    color: selectedValueString.isNotEmpty
                                        ? Colors.black87
                                        : Colors.grey[600],
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
                        String displayText = "Choose ${dimension.dimensionName}";
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
                                    color: Colors.black87,
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
                                            // 🔁 If already open → close it
                                            _hideOverlay();
                                            setState(() {
                                              _openDropdownIndex = null;
                                            });
                                          } else {
                                            // Close others & open this
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
                                        // 🔷 Added suffix tap handler via GestureDetector
                                        decoration: InputDecoration(
                                          hintText: 'Select...',
                                          hintStyle: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                          filled: true,
                                          fillColor: Colors.white,
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
                                              // 🔥 Tap on arrow closes dropdown
                                              if (_openDropdownIndex == index) {
                                                _hideOverlay();
                                                setState(() {
                                                  _openDropdownIndex = null;
                                                });
                                              } else {
                                                // Simulate field tap
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
                            child: const Text(
                              "Save",
                              style: TextStyle(color: Colors.white, fontSize: 13),
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
                            child: const Text(
                              "Cancel",
                              style: TextStyle(fontSize: 13),
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
                        labelText: "Percentage *",
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
                            "Amount: ${calculatedAmount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Report: ${calculatedAmount.toStringAsFixed(2)}",
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
              "Total percentage must equal 100%. Current: ${_totalPercentage.toStringAsFixed(2)}%",
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
                label: const Text("Add Split", style: TextStyle(fontSize: 13)),
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
                child: const Text('Cancel', style: TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 14),
              ElevatedButton(
                onPressed: () {
                  if (_totalPercentage != 100) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Total percentage must equal 100%. Current: ${_totalPercentage.toStringAsFixed(2)}%",
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
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white, fontSize: 13),
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

// import 'package:digi_xpense/core/constant/Parames/colors.dart';
// import 'package:digi_xpense/data/models.dart';
// import 'package:digi_xpense/data/service.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:uuid/uuid.dart';

// class AccountingDistributionWidget extends StatefulWidget {
//   final int? index;
//   final List<AccountingSplit> splits;
//   final double lineAmount;
//   final void Function(int index, AccountingSplit updatedSplit)? onChanged;
//   final void Function(List<AccountingDistribution>)? onDistributionChanged;

//   const AccountingDistributionWidget({
//     super.key,
//     this.index,
//     required this.splits,
//     required this.lineAmount,
//     this.onChanged,
//     this.onDistributionChanged,
//   });

//   @override
//   State<AccountingDistributionWidget> createState() =>
//       _AccountingDistributionWidgetState();
// }

// class _AccountingDistributionWidgetState
//     extends State<AccountingDistributionWidget> {
//   final controller = Get.put(Controller());

//   List<DimensionHierarchy> dimensionList = [];
//   List<DimensionValue> dimensionValueList = [];

//   Map<int, bool> isDropdownExpandedMap = {};
//   Map<int, Map<String, String?>> splitSelectedDimensionValues = {};

//   @override
//   void initState() {
//     super.initState();
//     if (controller.accountingDistributions.isNotEmpty) {
//       widget.splits.clear();
//       for (var dist in controller.accountingDistributions) {
//         widget.splits.add(AccountingSplit(
//           paidFor: dist?.dimensionValueId ?? '',
//           percentage: dist?.allocationFactor ?? 0.0,
//           amount: dist?.transAmount ?? 0.0,
//         ));
//         final splitIndex = widget.splits.length - 1;
//         final valueParts = (dist?.dimensionValueId ?? '').split(",");
//         final valueMap = <String, String?>{};
//         for (int j = 0; j < valueParts.length; j++) {
//           if (j < dimensionList.length) {
//             final dimensionId = dimensionList[j].dimensionId;
//             valueMap[dimensionId] = valueParts[j];
//           }
//         }
//         splitSelectedDimensionValues[splitIndex] = valueMap;
//       }
//     }
//     controller.digiSessionId = const Uuid().v4();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _loadDimensionData();
//     });
//   }

//   Future<void> _loadDimensionData() async {
//     try {
//       final dimensions = await controller.fetchDimensionHierarchies();
//       final values = await controller.fetchDimensionValues();
//       setState(() {
//         dimensionList = dimensions;
//         dimensionValueList = values;
//         for (int i = 0; i < widget.splits.length; i++) {
//           final paidFor = widget.splits[i].paidFor ?? '';
//           if (paidFor.isNotEmpty) {
//             final valueParts = paidFor.split(",");
//             final valueMap = <String, String?>{};
//             for (int j = 0; j < valueParts.length; j++) {
//               if (j < dimensionList.length) {
//                 final dimensionId = dimensionList[j].dimensionId;
//                 valueMap[dimensionId] = valueParts[j];
//               }
//             }
//             splitSelectedDimensionValues[i] = valueMap;
//           }
//         }
//       });
//     } catch (e) {
//       debugPrint("Error fetching dimension data: $e");
//     }
//   }

//   List<DropdownMenuItem<String>> _getDropdownItemsForDimension(
//       String dimensionId) {
//     final filtered = dimensionValueList
//         .where((val) => val.dimensionId == dimensionId)
//         .toSet() // ⚠️ Remove duplicates
//         .toList();
//     return filtered.map((e) {
//       return DropdownMenuItem<String>(
//         value: e.dimensionValueId,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
//           child: Text(
//             '${e.valueName} (${e.dimensionValueId})',
//             style: const TextStyle(
//               fontSize: 12,
//               color: Colors.black87,
//               fontWeight: FontWeight.w400,
//             ),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       );
//     }).toList();
//   }

//   void _addSplit() {
//     setState(() {
//       widget.splits.add(AccountingSplit(percentage: 100.0));
//       isDropdownExpandedMap[widget.splits.length - 1] = false;
//       splitSelectedDimensionValues[widget.splits.length - 1] = {};
//     });
//   }

//   void _removeSplit(int index) {
//     setState(() {
//       widget.splits.removeAt(index);
//       isDropdownExpandedMap.remove(index);
//       splitSelectedDimensionValues.remove(index);
//     });
//   }

//   double get _totalPercentage =>
//       widget.splits.fold(0.0, (sum, item) => sum + item.percentage);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         const SizedBox(height: 12),
//         ...widget.splits.asMap().entries.map((entry) {
//           final index = entry.key;
//           final split = entry.value;
//           final calculatedAmount = widget.lineAmount * (split.percentage / 100);
//           split.amount = calculatedAmount;
//           final selectedValues = splitSelectedDimensionValues[index] ?? {};
//           final selectedValueString =
//               selectedValues.values.whereType<String>().join(',');
//           return Card(
//             color: const Color.fromARGB(234, 214, 224, 247),
//             margin: const EdgeInsets.symmetric(vertical: 8),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//               side: BorderSide(color: Colors.grey.shade300),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Column(
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         isDropdownExpandedMap[index] =
//                             !(isDropdownExpandedMap[index] ?? false);
//                       });
//                     },
//                     child: Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade400),
//                         borderRadius: BorderRadius.circular(6),
//                         color: Colors.white,
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 10),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           // Scrollable text to handle overflow
//                           Expanded(
//                             child: SingleChildScrollView(
//                               scrollDirection: Axis.horizontal,
//                               child: Text(
//                                 selectedValueString.isNotEmpty
//                                     ? selectedValueString
//                                     : "Select Dimension",
//                                 style: TextStyle(
//                                   color: selectedValueString.isNotEmpty
//                                       ? Colors.black
//                                       : Colors.grey,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Icon(
//                             (isDropdownExpandedMap[index] ?? false)
//                                 ? Icons.keyboard_arrow_up
//                                 : Icons.keyboard_arrow_down,
//                             size: 18,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   if (isDropdownExpandedMap[index] ?? false) ...[
//                     const SizedBox(height: 6),
//                     ...dimensionList.map((dimension) {
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 6.0),
//                         child: LayoutBuilder(
//                           builder: (context, constraints) {
//                             final dropdownItems = _getDropdownItemsForDimension(
//                                 dimension.dimensionId);
//                             final currentValue = dropdownItems.any((item) =>
//                                     item.value ==
//                                     selectedValues[dimension.dimensionId])
//                                 ? selectedValues[dimension.dimensionId]
//                                 : null;
//                             return DropdownButtonFormField<String>(
//                               value: currentValue,
//                               decoration: InputDecoration(
//                                 labelText: dimension.dimensionName,
//                                 labelStyle: const TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.black87,
//                                 ),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(6),
//                                 ),
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 10,
//                                   vertical: 8,
//                                 ),
//                               ),
//                               isExpanded: true,
//                               icon: Icon(
//                                 isDropdownExpandedMap[index] == true
//                                     ? Icons.arrow_drop_up
//                                     : Icons.arrow_drop_down,
//                                 size: 18,
//                               ),
//                               dropdownColor: Colors.white,
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.black87,
//                               ),
//                               items: _getDropdownItemsForDimension(
//                                   dimension.dimensionId),
//                               onChanged: (value) {
//                                 setState(() {
//                                   splitSelectedDimensionValues[index] ??= {};
//                                   splitSelectedDimensionValues[index]![
//                                       dimension.dimensionId] = value;
//                                 });
//                               },
//                             );
//                           },
//                         ),
//                       );
//                     }).toList(),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         ElevatedButton(
//                           onPressed: () {
//                             setState(() {
//                               isDropdownExpandedMap[index] = false;
//                               final savedValues =
//                                   splitSelectedDimensionValues[index] ?? {};
//                               final dimensionIds = savedValues.values
//                                   .whereType<String>()
//                                   .join(',');
//                               print(
//                                   "Selected dimensions for Split $index: $savedValues");
//                               print(
//                                   "Saved dimension IDs (joined): $dimensionIds");
//                               widget.splits[index] = split.copyWith(
//                                 paidFor: dimensionIds,
//                               );
//                             });
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.gradientEnd,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 8),
//                           ),
//                           child: const Text(
//                             "Save",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 6),
//                         ElevatedButton(
//                           onPressed: () {
//                             setState(() {
//                               isDropdownExpandedMap[index] = false;
//                             });
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.grey[300],
//                             foregroundColor: Colors.black,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 8),
//                           ),
//                           child: const Text(
//                             "Cancel",
//                             style: TextStyle(fontSize: 12),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                   const SizedBox(height: 10),
//                   TextFormField(
//                     initialValue: split.percentage.toString(),
//                     keyboardType: TextInputType.number,
//                     decoration: const InputDecoration(
//                       labelText: "Percentage *",
//                       labelStyle: TextStyle(fontSize: 12),
//                       border: OutlineInputBorder(),
//                       contentPadding:
//                           EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                     ),
//                     style: const TextStyle(fontSize: 12),
//                     onChanged: (value) {
//                       final parsed = double.tryParse(value) ?? 0.0;
//                       final updated = split.copyWith(
//                         percentage: parsed,
//                         amount: widget.lineAmount * (parsed / 100),
//                       );
//                       setState(() {
//                         widget.splits[index] = updated;
//                       });
//                       widget.onChanged?.call(index, updated);
//                     },
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "Amount: ${calculatedAmount.toStringAsFixed(2)}",
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w500,
//                           fontSize: 12,
//                         ),
//                       ),
//                       Text(
//                         "Report: ${calculatedAmount.toStringAsFixed(2)}",
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w500,
//                           fontSize: 12,
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.delete,
//                             color: Colors.red, size: 18),
//                         onPressed: () => _removeSplit(index),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           );
//         }).toList(),
//         if (_totalPercentage != 100)
//           Padding(
//             padding: const EdgeInsets.only(top: 8),
//             child: Text(
//               "Total percentage must equal 100%. Current: ${_totalPercentage.toStringAsFixed(2)}%",
//               style: const TextStyle(
//                 color: Colors.red,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         const SizedBox(height: 10),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             ElevatedButton.icon(
//               onPressed: _addSplit,
//               icon: const Icon(Icons.add, size: 16),
//               label: const Text(
//                 "Add Split",
//                 style: TextStyle(fontSize: 12),
//               ),
//               style: ElevatedButton.styleFrom(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//               ),
//             ),
//             const SizedBox(width: 12),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.grey[300],
//                 foregroundColor: Colors.black,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//               ),
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(fontSize: 12),
//               ),
//             ),
//             const SizedBox(width: 12),
//             ElevatedButton(
//               onPressed: () {
//                 if (_totalPercentage != 100) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                         "Total percentage must equal 100%. Current: ${_totalPercentage.toStringAsFixed(2)}%",
//                       ),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                   return;
//                 }
//                 final distributions = widget.splits.map((split) {
//                   final amount = split.amount ?? 0.0;
//                   return AccountingDistribution(
//                     transAmount: double.parse(amount.toStringAsFixed(2)),
//                     reportAmount: double.parse(amount.toStringAsFixed(2)),
//                     allocationFactor: split.percentage,
//                     dimensionValueId: split.paidFor ?? '',
//                   );
//                 }).toList();

//                 widget.onDistributionChanged?.call(distributions);
//                 Navigator.of(context).pop();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.gradientEnd,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//               ),
//               child: const Text(
//                 'Save',
//                 style: TextStyle(color: Colors.white, fontSize: 12),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//       ],
//     );
//   }
// }
