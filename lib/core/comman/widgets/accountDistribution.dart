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
  List<PaidForModel> paidForOptions = [];
  final controller = Get.put(Controller());

  @override
  void initState() {
    super.initState();
    if (controller.isManualEntry) {
      controller.split.assignAll(
        controller.accountingDistributions.map((e) {
          return AccountingSplit(
            paidFor: e!.dimensionValueId,
            percentage: e.allocationFactor,
            amount: e.transAmount,
          );
        }).toList(),
      );
    }
    controller.digiSessionId = const Uuid().v4();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.fetchPaidForList().then((data) {
        setState(() {
          paidForOptions = data;
        });
      });
    });
  }

  void _addSplit() {
    setState(() {
      widget.splits.add(AccountingSplit(percentage: 0.0));
    });
  }

  void _removeSplit(int index) {
    setState(() {
      widget.splits.removeAt(index);
    });
  }

  void _clearSplits() {
    setState(() {
      widget.splits
        ..clear()
        ..add(AccountingSplit(percentage: 100.0));
    });
  }

  @override
  void dispose() {
    _clearSplits();
    super.dispose();
  }

  double get _totalPercentage =>
      widget.splits.fold(0.0, (sum, item) => sum + item.percentage);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...widget.splits.asMap().entries.map((entry) {
          final index = entry.key;
          final split = entry.value;
          final calculatedAmount = widget.lineAmount * (split.percentage / 100);
          split.amount = calculatedAmount;

          return Card(
            shadowColor: Colors.black,
            color: const Color.fromARGB(234, 214, 224, 247),
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: paidForOptions
                            .any((e) => e.dimensionValueId == split.paidFor)
                        ? split.paidFor
                        : null,
                    decoration: const InputDecoration(
                      labelText: "Paid For *",
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: paidForOptions
                        .map((e) => DropdownMenuItem(
                              value: e.dimensionValueId,
                              child: Text(
                                  '${e.valueName} (${e.dimensionValueId})'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      final updated = split.copyWith(paidFor: value);
                      setState(() {
                        widget.splits[index] = updated;
                      });
                      widget.onChanged?.call(index, updated);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: split.percentage.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Percentage *",
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
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
                      Text(
                        "Amount: ${calculatedAmount.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "Report Amount: ${calculatedAmount.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeSplit(index),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        if (_totalPercentage != 100)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "The total percentage must equal 100%. Current: ${_totalPercentage.toStringAsFixed(2)}%",
              style: const TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: _addSplit,
              icon: const Icon(Icons.add),
              label: const Text("Add Split"),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                _clearSplits();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 16),
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
                  return AccountingDistribution(
                    transAmount: double.parse(split.amount!.toStringAsFixed(2)),
                    reportAmount:
                        double.parse(split.amount!.toStringAsFixed(2)),
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
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
