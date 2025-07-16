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

  Map<int, bool> isDropdownExpandedMap = {};
  Map<int, Map<String, String?>> splitSelectedDimensionValues = {};

  @override
  void initState() {
    super.initState();
    if (controller.accountingDistributions.isNotEmpty) {
      widget.splits.clear();
      for (var dist in controller.accountingDistributions) {
        widget.splits.add(AccountingSplit(
          paidFor: dist?.dimensionValueId ?? '',
          percentage: dist?.allocationFactor ?? 0.0,
          amount: dist?.transAmount ?? 0.0,
        ));
        final splitIndex = widget.splits.length - 1;
        final valueParts = (dist?.dimensionValueId ?? '').split(",");
        final valueMap = <String, String?>{};
        for (int j = 0; j < valueParts.length; j++) {
          if (j < dimensionList.length) {
            final dimensionId = dimensionList[j].dimensionId;
            valueMap[dimensionId] = valueParts[j];
          }
        }
        splitSelectedDimensionValues[splitIndex] = valueMap;
      }
    }
    controller.digiSessionId = const Uuid().v4();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadDimensionData();
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
            final valueParts = paidFor.split(",");
            final valueMap = <String, String?>{};
            for (int j = 0; j < valueParts.length; j++) {
              if (j < dimensionList.length) {
                final dimensionId = dimensionList[j].dimensionId;
                valueMap[dimensionId] = valueParts[j];
              }
            }
            splitSelectedDimensionValues[i] = valueMap;
          }
        }
      });
    } catch (e) {
      debugPrint("Error fetching dimension data: $e");
    }
  }

  List<DropdownMenuItem<String>> _getDropdownItemsForDimension(
      String dimensionId) {
    final filtered = dimensionValueList
        .where((val) => val.dimensionId == dimensionId)
        .toList();
    return filtered.map((e) {
      return DropdownMenuItem<String>(
        value: e.dimensionValueId,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Text(
            '${e.valueName} (${e.dimensionValueId})',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }).toList();
  }

  void _addSplit() {
    setState(() {
      widget.splits.add(AccountingSplit(percentage: 100.0));
      isDropdownExpandedMap[widget.splits.length - 1] = false;
      splitSelectedDimensionValues[widget.splits.length - 1] = {};
    });
  }

  void _removeSplit(int index) {
    setState(() {
      widget.splits.removeAt(index);
      isDropdownExpandedMap.remove(index);
      splitSelectedDimensionValues.remove(index);
    });
  }

  double get _totalPercentage =>
      widget.splits.fold(0.0, (sum, item) => sum + item.percentage);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        ...widget.splits.asMap().entries.map((entry) {
          final index = entry.key;
          final split = entry.value;
          final calculatedAmount = widget.lineAmount * (split.percentage / 100);
          split.amount = calculatedAmount;
          final selectedValues = splitSelectedDimensionValues[index] ?? {};
          final selectedValueString =
              selectedValues.values.whereType<String>().join(',');
          return Card(
            color: const Color.fromARGB(234, 214, 224, 247),
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isDropdownExpandedMap[index] =
                            !(isDropdownExpandedMap[index] ?? false);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Scrollable text to handle overflow
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                selectedValueString.isNotEmpty
                                    ? selectedValueString
                                    : "Select Dimension",
                                style: TextStyle(
                                  color: selectedValueString.isNotEmpty
                                      ? Colors.black
                                      : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          Icon(
                            (isDropdownExpandedMap[index] ?? false)
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isDropdownExpandedMap[index] ?? false) ...[
                    const SizedBox(height: 6),
                    ...dimensionList.map((dimension) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return DropdownButtonFormField<String>(
                              value: selectedValues[dimension.dimensionId],
                              decoration: InputDecoration(
                                labelText: dimension.dimensionName,
                                labelStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),
                              isExpanded: true,
                              icon: Icon(
                                isDropdownExpandedMap[index] == true
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                                size: 18,
                              ),
                              dropdownColor: Colors.white,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                              items: _getDropdownItemsForDimension(
                                  dimension.dimensionId),
                              onChanged: (value) {
                                setState(() {
                                  splitSelectedDimensionValues[index] ??= {};
                                  splitSelectedDimensionValues[index]![
                                      dimension.dimensionId] = value;
                                });
                              },
                            );
                          },
                        ),
                      );
                    }).toList(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isDropdownExpandedMap[index] = false;
                              final savedValues =
                                  splitSelectedDimensionValues[index] ?? {};
                              final dimensionIds = savedValues.values
                                  .whereType<String>()
                                  .join(',');
                              print(
                                  "Selected dimensions for Split $index: $savedValues");
                              print(
                                  "Saved dimension IDs (joined): $dimensionIds");
                              widget.splits[index] = split.copyWith(
                                paidFor: dimensionIds,
                              );
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gradientEnd,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                          ),
                          child: const Text(
                            "Save",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isDropdownExpandedMap[index] = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: split.percentage.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Percentage *",
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    style: const TextStyle(fontSize: 12),
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
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Amount: ${calculatedAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Report: ${calculatedAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red, size: 18),
                        onPressed: () => _removeSplit(index),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        }).toList(),
        if (_totalPercentage != 100)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "Total percentage must equal 100%. Current: ${_totalPercentage.toStringAsFixed(2)}%",
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: _addSplit,
              icon: const Icon(Icons.add, size: 16),
              label: const Text(
                "Add Split",
                style: TextStyle(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(width: 12),
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
                    allocationFactor: split.percentage,
                    dimensionValueId: split.paidFor ?? '',
                  );
                }).toList();
              
                widget.onDistributionChanged?.call(distributions);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gradientEnd,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
