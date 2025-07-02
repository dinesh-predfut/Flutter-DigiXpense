// Full Updated Code with View/Edit Mode Toggle and Date Pickers
import 'package:digi_xpense/core/comman/widgets/accountDistribution.dart';
import 'package:digi_xpense/core/comman/widgets/button.dart';
import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';
import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CreatePerDiemPage extends StatefulWidget {
  final PerdiemResponseModel? item;
  const CreatePerDiemPage({super.key, this.item});

  @override
  State<CreatePerDiemPage> createState() => _CreatePerDiemPageState();
}

class _CreatePerDiemPageState extends State<CreatePerDiemPage>
    with SingleTickerProviderStateMixin {
  final controller = Get.put(Controller());
  bool isEditMode = false;
  late Future<List<ExpenseHistory>> historyFuture;
  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      historyFuture = controller.fetchExpenseHistory(widget.item!.recId);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.fetchLocation();

      isEditMode = widget.item == null;

      await _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final now = DateTime.now();
    final formatted = formatDate(now);

    controller.fromDateController.text = formatted;
    controller.toDateController.text = formatted;

    await Future.wait([
      controller.fetchProjectName(),
      controller.fetchPerDiemRates(),
    ]);

    if (widget.item != null) {
      final item = widget.item!;
      controller.isManualEntry = true;
      final matchedProject = controller.project.firstWhere(
        (p) => p.code == item.projectId,
        orElse: () => Project(name: '', code: '', isNotEmpty: true),
      );

      if (matchedProject.code.isNotEmpty) {
        controller.selectedProject = matchedProject;
        controller.ProjectIdController.text = matchedProject.code;
      }

      final matchedLocation = controller.location.firstWhere(
        (l) => l.location == item.location,
        // orElse: () => LocationModel(location: '', country: ''),
      );

      controller.selectedLocation = matchedLocation;
      controller.locationController.text = matchedLocation.location;

      controller.fromDateController.text = DateFormat('dd-MMM-yyyy')
          .format(DateTime.fromMillisecondsSinceEpoch(item.fromDate));
      controller.toDateController.text = DateFormat('dd-MMM-yyyy')
          .format(DateTime.fromMillisecondsSinceEpoch(item.toDate));

      controller.daysController.text = item.noOfDays.toString();
      controller.amountInController.text = item.totalAmountTrans.toString();
      controller.purposeController.text = item.description ?? '';
      historyFuture = controller.fetchExpenseHistory(item.recId);
      controller.allocationLines = item.allocationLines;
      controller.accountingDistributions = item.accountingDistributions;
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd-MMM-yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 11, 1, 61),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Create Per Diem",
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!isEditMode && widget.item != null)
            IconButton(
              icon: const Icon(Icons.edit_document),
              onPressed: () => setState(() => isEditMode = true),
            )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Per Diem Details",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SearchableMultiColumnDropdownField<Project>(
                labelText: 'Project Id *',
                items: controller.project,
                selectedValue: controller.selectedProject,
                enabled: isEditMode,
                controller: controller.ProjectIdController,
                searchValue: (proj) => '${proj.name} ${proj.code}',
                displayText: (proj) => proj.code,
                validator: (proj) =>
                    proj == null ? 'Please select a Project' : null,
                onChanged: (proj) {
                  controller.selectedProject = proj;
                  controller.fetchExpenseCategory();
                },
                columnHeaders: const ['Project Name', 'Project Id'],
                rowBuilder: (proj, searchQuery) {
                  Widget highlight(String text) {
                    final lowerQuery = searchQuery.toLowerCase();
                    final lowerText = text.toLowerCase();
                    final start = lowerText.indexOf(lowerQuery);
                    if (start == -1 || searchQuery.isEmpty) return Text(text);

                    final end = start + searchQuery.length;
                    return RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: text.substring(0, start),
                            style: const TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: text.substring(start, end),
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: text.substring(end),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(child: Text(proj.name)),
                        Expanded(child: Text(proj.code)),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              SearchableMultiColumnDropdownField<LocationModel>(
                labelText: 'Location *',
                items: controller.location,
                selectedValue: controller.selectedLocation,
                enabled: isEditMode,
                controller: controller.locationController,
                searchValue: (proj) => '${proj.location}',
                displayText: (proj) => proj.location,
                validator: (proj) =>
                    proj == null ? 'Please select a Location' : null,
                onChanged: (proj) {
                  controller.selectedLocation = proj;
                  controller.fetchPerDiemRates();
                },
                columnHeaders: const ['Location', 'Country'],
                rowBuilder: (proj, searchQuery) {
                  Widget highlight(String text) {
                    final lowerQuery = searchQuery.toLowerCase();
                    final lowerText = text.toLowerCase();
                    final start = lowerText.indexOf(lowerQuery);
                    if (start == -1 || searchQuery.isEmpty) return Text(text);

                    final end = start + searchQuery.length;
                    return RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: text.substring(0, start),
                            style: const TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: text.substring(start, end),
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: text.substring(end),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(child: Text(proj.location)),
                        Expanded(child: Text(proj.country)),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              buildDateField("From Date *", controller.fromDateController,
                  enabled: isEditMode),
              buildDateField("To Date *", controller.toDateController,
                  enabled: isEditMode),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: buildTextField(
                      "No of Days *",
                      controller.daysController,
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (widget.item == null)
                    SizedBox(
                      width: 50,
                      child: stylishSettingsButton(
                        onPressed: () {
                          _showSettingsPopup();
                        },
                      ),
                    ),
                ],
              ),
              buildTextField("Purpose", controller.purposeController,
                  readOnly: !isEditMode),
              buildTextField("Per Diem *", controller.perDiemController,
                  readOnly: true),
              buildTextField("Total Amount INR*", controller.amountInController,
                  readOnly: true),
              if (isEditMode)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        final double lineAmount = double.tryParse(
                                controller.amountInController.text) ??
                            0.0;

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (context) => Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                              left: 16,
                              right: 16,
                              top: 24,
                            ),
                            child: SingleChildScrollView(
                              child: AccountingDistributionWidget(
                                splits: controller.split,
                                lineAmount: lineAmount,
                                onChanged: (i, updatedSplit) {
                                  if (!mounted) return;
                                  controller.split[i] = updatedSplit;
                                },
                                onDistributionChanged: (newList) {
                                  if (!mounted) return;
                                  controller.accountingDistributions
                                      .clear(); // optional: clear first
                                  controller.accountingDistributions
                                      .addAll(newList);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                      child: const Text('Account Distribution'),
                    ),
                  ],
                ),
              if (widget.item != null) const SizedBox(height: 10),
              if (widget.item != null)
                _buildSection(
                  title: "Tracking History",
                  children: [
                    const SizedBox(height: 12),
                    FutureBuilder<List<ExpenseHistory>>(
                      future: historyFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        final historyList = snapshot.data!;
                        if (historyList.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'The expense does not have a history. Please consider submitting it for approval.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }
                        print("historyList: $historyList");
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: historyList.length,
                          itemBuilder: (context, index) {
                            final item = historyList[index];
                            print("Trackingitem: $item");
                            return _buildTimelineItem(
                              item,
                              index == historyList.length - 1,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              if (isEditMode)
                Obx(() {
                  return SizedBox(
                    width: double.infinity, // Make button full width
                    child: GradientButton(
                        text: "Submit",
                        isLoading: controller.buttonLoader.value,
                        onPressed: () {
                          if (widget.item == null) {
                            controller.updatePerDiemDetails(
                                context, true, false, null);
                          } else {
                            controller.updatePerDiemDetails(
                                context, true, false, widget.item!.expenseId);
                          }
                        }),
                  );
                }),
              if (isEditMode) const SizedBox(height: 20),
              if (isEditMode)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (widget.item == null) {
                            controller.updatePerDiemDetails(
                                context, false, false, null);
                          } else {
                            controller.updatePerDiemDetails(
                                context, false, false, widget.item!.expenseId);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8E6EFF)),
                        child: const Text("Save"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey),
                        child: const Text("Cancel"),
                      ),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text("Cancel"),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: readOnly ? Colors.grey.shade200 : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget buildDateField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: enabled
            ? () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  controller.text = formatDate(picked);
                }
              }
            : null,
        child: AbsorbPointer(
          child: TextField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              labelText: label,
              filled: true,
              fillColor: enabled ? Colors.white : Colors.grey.shade200,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.deepPurple,
              ),
            ),
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,
            textColor: Colors.deepPurple,
            iconColor: Colors.deepPurple,
            collapsedIconColor: Colors.grey,
            childrenPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(ExpenseHistory item, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.blue),
            if (!isLast)
              Container(width: 2, height: 40, color: Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.eventType,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(item.notes),
                  const SizedBox(height: 6),
                  Text(
                    'Submitted on ${DateFormat('dd/MM/yyyy').format(item.createdDate)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget stylishSettingsButton({
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade400, width: 1),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: const Icon(Icons.settings, size: 18, color: Colors.black87),
      ),
    );
  }

  void _showSettingsPopup() {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      context: context,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Allocation Settings',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...controller.allocationLines
                    .map((line) => _buildAllocationCard(line, isPopup: true)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        for (var data in controller.allocationLines) {
                          if (controller.setTheAllcationAmount == 0) {
                            print("Its True");
                            controller.setTheAllcationAmount =
                                data.unitPriceTrans.toInt();
                          }
                          if (data.parsed == 0.0) {
                            data.unitPriceTrans =
                                controller.setTheAllcationAmount *
                                    data.quantity;
                          } else {
                            data.unitPriceTrans =
                                controller.setTheAllcationAmount * data.parsed;
                            data.quantity = data.parsed;
                          }

                          print(
                              "Cleared input. Reset quantity to ${data.quantity}");
                          print("Updated total: ${data.unitPriceTrans}");
                          print(
                              " controller.setTheAllcationAmount: ${controller.setTheAllcationAmount}");
                        }

                        double updatedTotal = controller.allocationLines.fold(
                          0.0,
                          (sum, item) => sum + item.unitPriceTrans,
                        );
                        // print("Cleared input. Reset quantity to 0.");
                        print("Updated total: $updatedTotal");
                        controller.amountInController.text =
                            updatedTotal.toStringAsFixed(2);
                        // controller.updatePerDiemDetails();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gradientEnd,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllocationCard(AllocationLine data, {bool isPopup = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildReadonlyField(
                  label: 'Effective From',
                  value: _formatDate(
                      DateTime.fromMillisecondsSinceEpoch(data.effectiveFrom)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildReadonlyField(
                  label: 'Allowance Category',
                  value: data.expenseCategoryId,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildReadonlyField(
                  label: 'Effective To',
                  value: _formatDate(
                      DateTime.fromMillisecondsSinceEpoch(data.effectiveTo)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _buildEditableDaysField(data)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadonlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(value, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildEditableDaysField(AllocationLine data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('No. of Days',
            style: TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 4),
        SizedBox(
          width: 110,
          height: 40,
          child: TextFormField(
              initialValue: data.quantity.toString(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (val) {
                // double perDayRate = data.quantity;
                if (val.isEmpty) {
                  setState(() {
                    data.parsed = 0;
                  });
                  return; // Exit early
                }

                final parsed = double.tryParse(val);
                if (parsed != null && parsed > 0) {
                  print("parsed total: $parsed");
                  setState(() {
                    data.parsed = parsed;
                  });
                }
              }),
        )
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}/${dt.year}';
  }
}
