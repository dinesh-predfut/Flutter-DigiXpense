// Full Updated Code with View/Edit Mode Toggle and Date Pickers
import 'package:digi_xpense/core/comman/widgets/accountDistribution.dart';
import 'package:digi_xpense/core/comman/widgets/button.dart';
import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';
import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
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
  bool _showProjectError = false;
  bool _showLocationError = false;
  late final int workitemrecid;
  late Future<List<ExpenseHistory>> historyFuture;
  @override
  void initState() {
    super.initState();
    controller.fetchCustomFields();
    controller.configuration();
    if(widget.item == null){
        setState(() {
         controller.isEditModePerdiem = true;
      });
    }
    // if(widget.item == null){

    //      controller.isEditModePerdiem = false;

    // }
    // controller.clearFormFieldsPerdiem();
    if (widget.item != null) {
      setState(() {
         controller.isEditModePerdiem = false;
      });
     

      if (widget.item!.workitemrecid != null) {
        workitemrecid = widget.item!.workitemrecid!;
      }

      historyFuture = controller.fetchExpenseHistory(widget.item!.recId);
      controller.split =
          (widget.item!.accountingDistributions ?? []).map((dist) {
        return AccountingSplit(
          paidFor: dist.dimensionValueId ?? '',
          percentage: dist.allocationFactor ?? 0.0,
          amount: dist.transAmount ?? 0.0,
        );
      }).toList();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.fetchLocation();
      if (widget.item != null) {
        // controller.isEditModePerdiem = widget.item != null;
      }
      await _initializeData();
    });
  }

  bool isFieldMandatory(String fieldName) {
    return controller.configList.any(
      (f) =>
          (f['FieldName']?.toString().trim().toLowerCase() ==
              fieldName.trim().toLowerCase()) &&
          (f['IsEnabled'].toString().toLowerCase() == 'true') &&
          (f['IsMandatory'].toString().toLowerCase() == 'true'),
    );
  }

  bool validateForm() {
    bool isValid = true;

    setState(() {
      // Validate Tax Amount

      // Validate Project Id
      final projectMandatory = isFieldMandatory('Project Id');
      if (controller.selectedProject == null && projectMandatory) {
        _showProjectError = true;
        isValid = false;
      } else {
        _showProjectError = false;
      }

      // Validate Location
      final locationMandatory = isFieldMandatory('Location');
      if (controller.selectedLocation == null && locationMandatory) {
        _showLocationError = true;
        isValid = false;
      } else {
        _showLocationError = false;
      }

      // Validate Custom Fields
      for (var field in controller.customFields) {
        final bool isCustomMandatory =
            (field['IsMandatory'].toString().toLowerCase() == 'true');
        final value = field['FieldType'] == 'List'
            ? field['SelectedValue']
            : field['EnteredValue'];

        if (isCustomMandatory && (value == null || value.toString().isEmpty)) {
          field['Error'] = 'Please enter ${field['FieldLabel']}';
          isValid = false;
        } else {
          field['Error'] = null; // Clear error
        }
      }
    });

    return isValid;
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
      print("Its Called ");
      final item = widget.item!;
      // controller.isEditModePerdiem = true;
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
      controller.expenseIdController.text = item.expenseId;
      controller.employeeIdController.text = item.employeeId!;
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
    // ignore: deprecated_member_use
    return WillPopScope(
        onWillPop: () async {
          controller.clearFormFieldsPerdiem();
          Navigator.pushNamed(context, AppRoutes.dashboard_Main);
          controller.isEditModePerdiem = true;
          return true; // allow back navigation
        },
        child: Scaffold(
            backgroundColor: const Color.fromARGB(255, 11, 1, 61),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text("Create Per Diem",
                  style: TextStyle(color: Colors.white)),
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                if (!controller.isEditModePerdiem && widget.item != null && widget.item!.approvalStatus != "Approved")
                  IconButton(
                    icon: const Icon(Icons.edit_document),
                    onPressed: () =>
                        setState(() => controller.isEditModePerdiem = true),
                  )
              ],
            ),
            body: Obx(() {
              return controller.isLoadingGE2.value
                  ? const SkeletonLoaderPage()
                  : Container(
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
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            if (widget.item != null)
                              buildTextField("Expense ID *",
                                  controller.expenseIdController,
                                  readOnly: true),
                            if (widget.item != null)
                              buildTextField("Employee ID *",
                                  controller.employeeIdController,
                                  readOnly: true),
                            ...controller.configList
                                .where((field) =>
                                    field['FieldName'] == 'Project Id' &&
                                    field['FieldName'] !=
                                        'Location') // 👈 filter only Project Id
                                .map((field) {
                              final String label = field['FieldName'];
                              final bool isMandatory =
                                  field['IsMandatory'] ?? false;

                              Widget inputField;

                              // Project dropdown logic
                              inputField = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SearchableMultiColumnDropdownField<Project>(
                                    labelText:
                                        'Project Id ${isMandatory ? "*" : ""}',
                                    columnHeaders: const [
                                      'Project Name',
                                      'Project Id'
                                    ],
                                    enabled: controller.isEditModePerdiem,
                                    controller: controller.ProjectIdController,
                                    items: controller.project,
                                    selectedValue: controller.selectedProject,
                                    searchValue: (proj) =>
                                        '${proj.name} ${proj.code}',
                                    displayText: (proj) => proj.code,
                                    onChanged: (proj) {
                                      setState(() {
                                        controller.selectedProject = proj;
                                        controller.selectedProject = proj;
                                        if (proj != null) {
                                          _showProjectError = false;
                                        }
                                      });
                                      // controller.fetchExpenseCategory();
                                    },
                                    rowBuilder: (proj, searchQuery) {
                                      Widget highlight(String text) {
                                        final lowerQuery =
                                            searchQuery.toLowerCase();
                                        final lowerText = text.toLowerCase();
                                        final start =
                                            lowerText.indexOf(lowerQuery);
                                        if (start == -1 || searchQuery.isEmpty)
                                          return Text(text);

                                        final end = start + searchQuery.length;
                                        return RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: text.substring(0, start),
                                                style: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                              TextSpan(
                                                text:
                                                    text.substring(start, end),
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                text: text.substring(end),
                                                style: const TextStyle(
                                                    color: Colors.black),
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
                                            Expanded(
                                                child: highlight(proj.name)),
                                            Expanded(
                                                child: highlight(proj.code)),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  if (_showProjectError)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Please select a Project',
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 12),
                                      ),
                                    ),
                                ],
                              );

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  inputField,
                                  const SizedBox(height: 16),
                                ],
                              );
                            }).toList(),
                            ...controller.configList
                                .where((field) =>
                                    field['FieldName'] == 'Location' &&
                                    field['IsEnabled'] ==
                                        true) // 👈 Only show if enabled
                                .map((field) {
                              final bool isMandatory =
                                  field['IsMandatory'] ?? false;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SearchableMultiColumnDropdownField<
                                      LocationModel>(
                                    labelText:
                                        'Location ${isMandatory ? "*" : ""}',
                                    items: controller.location,
                                    selectedValue: controller.selectedLocation,
                                    enabled: controller.isEditModePerdiem,
                                    controller: controller.locationController,
                                    searchValue: (proj) => proj.location,
                                    displayText: (proj) => proj.location,
                                    validator: (proj) =>
                                        isMandatory && proj == null
                                            ? 'Please select a Location'
                                            : null,
                                    onChanged: (proj) {
                                      controller.selectedLocation = proj;
                                      controller.fetchPerDiemRates();
                                      field['Error'] =
                                          null; // Clear error when value selected
                                    },
                                    columnHeaders: const [
                                      'Location',
                                      'Country'
                                    ],
                                    rowBuilder: (proj, searchQuery) {
                                      Widget highlight(String text) {
                                        final lowerQuery =
                                            searchQuery.toLowerCase();
                                        final lowerText = text.toLowerCase();
                                        final start =
                                            lowerText.indexOf(lowerQuery);
                                        if (start == -1 ||
                                            searchQuery.isEmpty) {
                                          return Text(text);
                                        }

                                        final end = start + searchQuery.length;
                                        return RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: text.substring(0, start),
                                                style: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                              TextSpan(
                                                text:
                                                    text.substring(start, end),
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                text: text.substring(end),
                                                style: const TextStyle(
                                                    color: Colors.black),
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
                                            Expanded(
                                                child: Text(proj.location)),
                                            Expanded(child: Text(proj.country)),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  if (_showLocationError)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Please select a Location',
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 12),
                                      ),
                                    ),
                                ],
                              );
                            }).toList(),

                            // const SizedBox(height: 14),
                            // SearchableMultiColumnDropdownField<LocationModel>(
                            //   labelText: 'Location *',
                            //   items: controller.location,
                            //   selectedValue: controller.selectedLocation,
                            //   enabled: controller.isEditModePerdiem,
                            //   controller: controller.locationController,
                            //   searchValue: (proj) => '${proj.location}',
                            //   displayText: (proj) => proj.location,
                            //   validator: (proj) => proj == null
                            //       ? 'Please select a Location'
                            //       : null,
                            //   onChanged: (proj) {
                            //     controller.selectedLocation = proj;
                            //     controller.fetchPerDiemRates();
                            //   },
                            //   columnHeaders: const ['Location', 'Country'],
                            //   rowBuilder: (proj, searchQuery) {
                            //     Widget highlight(String text) {
                            //       final lowerQuery = searchQuery.toLowerCase();
                            //       final lowerText = text.toLowerCase();
                            //       final start = lowerText.indexOf(lowerQuery);
                            //       if (start == -1 || searchQuery.isEmpty)
                            //         return Text(text);

                            //       final end = start + searchQuery.length;
                            //       return RichText(
                            //         text: TextSpan(
                            //           children: [
                            //             TextSpan(
                            //               text: text.substring(0, start),
                            //               style: const TextStyle(
                            //                   color: Colors.black),
                            //             ),
                            //             TextSpan(
                            //               text: text.substring(start, end),
                            //               style: const TextStyle(
                            //                 color: Colors.black,
                            //               ),
                            //             ),
                            //             TextSpan(
                            //               text: text.substring(end),
                            //               style: const TextStyle(
                            //                   color: Colors.black),
                            //             ),
                            //           ],
                            //         ),
                            //       );
                            //     }

                            //     return Padding(
                            //       padding: const EdgeInsets.symmetric(
                            //           vertical: 12, horizontal: 16),
                            //       child: Row(
                            //         children: [
                            //           Expanded(child: Text(proj.location)),
                            //           Expanded(child: Text(proj.country)),
                            //         ],
                            //       ),
                            //     );
                            //   },
                            // ),
                            const SizedBox(height: 14),
                            buildDateField("From Date *",
                                controller.fromDateController, true,
                                enabled: controller.isEditModePerdiem),
                            buildDateField(
                                "To Date *", controller.toDateController, false,
                                enabled: controller.isEditModePerdiem),
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
                                if (widget.item == null )
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
                            buildTextField(
                                "Per Diem *", controller.perDiemController,
                                readOnly: true),
                            buildTextField("Total Amount INR*",
                                controller.amountInController,
                                readOnly: true),
                            buildTextField(
                                "Total Amount", controller.amountInController,
                                readOnly: true),
                            buildTextField(
                                "Purpose", controller.purposeController,
                                readOnly: controller.isEditModePerdiem),
                            Obx(() {
                              return Column(
                                children: controller.customFields.map((field) {
                                  final String label =
                                      field['FieldLabel'] ?? field['FieldName'];
                                  final bool isMandatory =
                                      field['IsMandatory'] ?? false;

                                  Widget inputField;

                                  if (field['FieldType'] == 'List') {
                                    inputField =
                                        DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText:
                                            '$label${isMandatory ? " *" : ""}',
                                        border: const OutlineInputBorder(),
                                      ),
                                      value: field[
                                          'SelectedValue'], // 👈 pre-fill selected value if any
                                      items: (field['Options']
                                                  as List<dynamic>?)
                                              ?.map((option) {
                                            return DropdownMenuItem<String>(
                                              value: option.toString(),
                                              child: Text(option.toString()),
                                            );
                                          }).toList() ??
                                          [],
                                      onChanged: (value) {
                                        // Save selected value in the field
                                        field['SelectedValue'] = value;
                                        controller.customFields
                                            .refresh(); // 👈 notify observers
                                      },
                                    );
                                  } else {
                                    inputField = TextField(
                                      decoration: InputDecoration(
                                        labelText:
                                            '$label${isMandatory ? " *" : ""}',
                                        border: const OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        // Save entered value in the field
                                        field['EnteredValue'] = value;
                                        controller.customFields
                                            .refresh(); // 👈 notify observers
                                      },
                                    );
                                  }

                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: inputField,
                                  );
                                }).toList(),
                              );
                            }),

                            if (controller.isEditModePerdiem)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      final double lineAmount = double.tryParse(
                                              controller
                                                  .amountInController.text) ??
                                          0.0;

                                      if (controller.split.isEmpty &&
                                          controller.accountingDistributions
                                              .isNotEmpty) {
                                        controller.split.assignAll(
                                          controller.accountingDistributions
                                              .map((e) {
                                            return AccountingSplit(
                                              paidFor: e!.dimensionValueId,
                                              percentage: e.allocationFactor,
                                              amount: e.transAmount,
                                            );
                                          }).toList(),
                                        );
                                      } else if (controller.split.isEmpty) {
                                        controller.split.add(
                                            AccountingSplit(percentage: 100.0));
                                      }

                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(16)),
                                        ),
                                        builder: (context) => Padding(
                                          padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom,
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
                                                controller.split[i] =
                                                    updatedSplit;
                                              },
                                              onDistributionChanged: (newList) {
                                                if (!mounted) return;
                                                controller
                                                    .accountingDistributions
                                                    .clear();
                                                controller
                                                    .accountingDistributions
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
                                            child: Text(
                                                'Error: ${snapshot.error}'));
                                      }

                                      final historyList = snapshot.data!;
                                      if (historyList.isEmpty) {
                                        return const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(16),
                                            child: Text(
                                              'The expense does not have a history. Please consider submitting it for approval.',
                                              textAlign: TextAlign.center,
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          ),
                                        );
                                      }
                                      print("historyList: $historyList");
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
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
                            // const SizedBox(height: 20),
                            const SizedBox(height: 20),

// Submit Button
                            if (controller.isEditModePerdiem &&
                                widget.item != null &&
                                widget.item!.approvalStatus == "Created" )
                              Obx(() {
                                return SizedBox(
                                  width: double.infinity, // Full width button
                                  child: GradientButton(
                                    text: "Submit",
                                    isLoading: controller.buttonLoader.value,
                                    onPressed: () {
                                      if (validateForm()) {
                                        controller.updatePerDiemDetails(
                                          context,
                                          true,
                                          false,
                                          null,
                                        );
                                      } else {
                                        print("Validation failed");
                                      }
                                    },
                                  ),
                                );
                              }),

// Save & Cancel Buttons (when creating)
                            if (controller.isEditModePerdiem &&
                                widget.item != null &&
                                widget.item!.approvalStatus == "Created") ...[
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (validateForm()) {
                                          controller.updatePerDiemDetails(
                                            context,
                                            false,
                                            false,
                                            null,
                                          );
                                        } else {
                                          print("Validation failed");
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color.fromARGB(255, 28, 114, 2),
                                      ),
                                      child: const Text("Save",style: TextStyle(color: Colors.white),),
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
                              ),
                            ],
                            if (controller.isEditModePerdiem &&
                                widget.item == null)
                              Obx(() {
                                return SizedBox(
                                  width: double.infinity, // Full width button
                                  child: GradientButton(
                                    text: "Submit",
                                    isLoading: controller.buttonLoader.value,
                                    onPressed: () {
                                      if (validateForm()) {
                                        controller.updatePerDiemDetails(
                                          context,
                                          true,
                                          false,
                                          null,
                                        );
                                      } else {
                                        print("Validation failed");
                                      }
                                    },
                                  ),
                                );
                              }),

// Save & Cancel Buttons (when creating)
                            if (controller.isEditModePerdiem &&
                               widget.item == null ) ...[
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (validateForm()) {
                                          controller.updatePerDiemDetails(
                                            context,
                                            false,
                                            false,
                                            null,
                                          );
                                        } else {
                                          print("Validation failed");
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF8E6EFF),
                                      ),
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
                              ),
                            ],
// Cancel & Close Buttons (Pending approval)
                            if (controller.isEditModePerdiem &&
                                widget.item != null &&
                                widget.item!.approvalStatus == "Pending" && widget.item!.stepType == null)
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        controller.cancelExpense(
                                          context,
                                          widget.item!.recId.toString(),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 233, 151, 151),
                                      ),
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          controller.chancelButton(context),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey),
                                      child: const Text(
                                        "Close",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

// Resubmit Button (Rejected)
                            if (controller.isEditModePerdiem &&
                                widget.item != null &&
                                widget.item!.approvalStatus == "Rejected")
                              Column(
                                children: [
                                  Obx(() {
                                    return SizedBox(
                                      width: double.infinity,
                                      child: GradientButton(
                                        text: "Resubmit",
                                        isLoading:
                                            controller.buttonLoader.value,
                                        onPressed: () {
                                          if (validateForm()) {
                                            controller.updatePerDiemDetails(
                                              context,
                                              true,
                                              true,
                                              widget.item!.recId,
                                              widget.item!.expenseId.toString(),
                                            );
                                          } else {
                                            print("Validation failed");
                                          }
                                        },
                                      ),
                                    );
                                  }),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (validateForm()) {
                                              controller.updatePerDiemDetails(
                                                context,
                                                false,
                                                false,
                                                widget.item!.recId,
                                                widget.item!.expenseId
                                                    .toString(),
                                              );
                                            } else {
                                              print("Validation failed");
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Color.fromARGB(255, 20, 94, 2),
                                          ),
                                          child: const Text("Update",
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              controller.chancelButton(context),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey),
                                          child: const Text(
                                            "Close",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                            const SizedBox(height: 20),

// Review Buttons (Update & Accept / Reject / Close)
                            if (controller.isEditModePerdiem &&
                                widget.item != null &&
                                widget.item!.stepType == "Review") ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (validateForm()) {
                                          controller.perdiemApprovalReview(
                                            context,
                                            false,
                                            widget.item!.workitemrecid,
                                            widget.item!.recId.toString(),
                                            widget.item!.expenseId.toString(),
                                          );
                                        } else {
                                          print("Validation failed");
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 3, 20, 117),
                                      ),
                                      child: const Text("Update",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        controller.perdiemApprovalReview(
                                          context,
                                          true,
                                          widget.item!.workitemrecid,
                                          widget.item!.recId.toString(),
                                          widget.item!.expenseId.toString(),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 3, 20, 117),
                                      ),
                                      child: const Text("Update & Accept",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        showActionPopup(context, "Reject");
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 238, 20, 20),
                                      ),
                                      child: const Text("Reject",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          controller.chancelButton(context),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey),
                                      child: const Text(
                                        "Close",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],

// Approval Buttons (Approve / Reject / Escalate / Close)
                            if (controller.isEditModePerdiem &&
                                widget.item != null &&
                                widget.item!.stepType == "Approval") ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        showActionPopup(context, "Approve");
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 30, 117, 3),
                                      ),
                                      child: const Text("Approve",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        showActionPopup(context, "Reject");
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 238, 20, 20),
                                      ),
                                      child: const Text("Reject",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        showActionPopup(context, "Escalate");
                                        // Escalate logic
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 3, 20, 117),
                                      ),
                                      child: const Text("Escalate",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          controller.chancelButton(context),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey),
                                      child: const Text(
                                        "Close",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],

// Cancel Button (default)
                            if (!controller.isEditModePerdiem)
                              ElevatedButton(
                                onPressed: () =>
                                    controller.chancelButton(context),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey),
                                child: const Text("Cancel",
                                    style: TextStyle(color: Colors.black)),
                              )
                          ],
                        ),
                      ),
                    );
            })));
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

  Widget buildDateField(
      String label, TextEditingController controllers, bool showDatePickerOnTap,
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
                  lastDate: DateTime.now(), // Disable future dates
                );
                if (picked != null) {
                  if (showDatePickerOnTap) {
                    controller.selectedDate = picked;
                  }
                  controllers.text = formatDate(picked);
                  controller.fetchPerDiemRates();
                }
              }
            : null,
        child: AbsorbPointer(
          child: TextField(
            controller: controllers,
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

 void showActionPopup(BuildContext context, String status) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Full height if needed
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final TextEditingController commentController = TextEditingController();

        return Padding(
          padding: MediaQuery.of(context).viewInsets, // for keyboard
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Action",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (status == "Escalate") ...[
                  const Text(
                    'Select User *',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  SearchableMultiColumnDropdownField<User>(
                    labelText: 'User *',
                
                    columnHeaders: const [
                      'User Name',
                      'User ID',
                    ],
                    items: controller.userList, // Assuming you have a user list
                    selectedValue: controller.selectedUser.value,
                    searchValue: (user) => '${user.userName} ${user.userId}',
                    displayText: (user) => user.userName,
                    onChanged: (user) {
                      // controller.selectedUser = user;
                      controller.userIdController.text = user?.userId ?? '';
                    },
                    controller: controller.userIdController,
                    rowBuilder: (user, searchQuery) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(child: Text(user.userName)),
                            Expanded(child: Text(user.userId)),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Comment',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter your comment here',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the popup
                      },
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final comment = commentController.text.trim();
                        if (comment.isNotEmpty) {
                          final success = await controller.postApprovalAction(
                            context,
                            workitemrecid: [workitemrecid],
                            decision: status,
                            comment: commentController.text,
                          );
                          if (!context.mounted) return;
                          if (success) {
                            Navigator.pushNamed(context,
                                AppRoutes.approvalDashboard); // Close popup
                          } else {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Failed to submit action')),
                            );
                          }

                          // Navigator.pop(context); // Close after action
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(status),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
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

 Future<void> _showSettingsPopup() async {
  await showModalBottomSheet(
    isScrollControlled: true, // Important for keyboard push-up
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    context: context,
    builder: (_) {
      return Padding(
        // Push content above keyboard
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Allocation Settings',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  if (controller.allocationLines.isNotEmpty)
                    ...controller.allocationLines.map(
                      (line) =>
                          _buildAllocationCard(line, isPopup: true),
                    ),

                  if (controller.allocationLines.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        "No allocation data found for your selected Location. Try another Location.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),

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
                              controller.setTheAllcationAmount =
                                  data.unitPriceTrans.toInt();
                            }
                            if (data.parsed == 0.0) {
                              data.unitPriceTrans =
                                  controller.setTheAllcationAmount *
                                      data.quantity;
                            } else {
                              data.unitPriceTrans =
                                  controller.setTheAllcationAmount *
                                      data.parsed;
                              data.quantity = data.parsed;
                            }
                          }
                          double updatedTotal =
                              controller.allocationLines.fold(
                            0.0,
                            (sum, item) => sum + item.unitPriceTrans,
                          );
                          controller.amountInController.text =
                              updatedTotal.toStringAsFixed(2);
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
            );
          },
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
