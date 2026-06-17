import 'package:diginexa/core/comman/widgets/pageLoaders.dart';
import 'package:diginexa/core/comman/widgets/searchDropown.dart';
import 'package:diginexa/core/constant/Parames/colors.dart';
import 'package:diginexa/data/models.dart';
import 'package:diginexa/data/pages/screen/widget/router/router.dart';
import 'package:diginexa/data/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import '../../../../../core/comman/widgets/multiselectDropdown.dart';
import '../../../../../l10n/app_localizations.dart';

class HubMileageFirstFrom extends StatefulWidget {
  final ExpenseModelMileage? mileageId;
  const HubMileageFirstFrom({super.key, this.mileageId});

  @override
  State<HubMileageFirstFrom> createState() => _HubMileageFirstFromState();
}

class _HubMileageFirstFromState extends State<HubMileageFirstFrom>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<Controller>();
  Future<List<ExpenseHistory>>? historyFuture;
  bool _showProjectError = false;
  bool allowMultSelect = false;
  String selectedProject = '';
  String? projectError;
  String? vehicleError;
  String expenseId = '';
    final Map<String, TextEditingController> fieldControllers = {};

  String employeeId = '';
  final List<String> projectList = ['Project A', 'Project B', 'Project C'];
  @override
  void initState() {
    super.initState();
    final dateTime = controller.selectedDateMileage ??= DateTime.now();
    final formattedDate = DateFormat(controller.selectedFormat?.key ?? 'dd/MM/yyyy').format(dateTime);
    controller.mileagDateController.text = formattedDate;
    _loadSettings();  
    // Delay your logic safely
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.fetchProjectName();
      await controller.fetchMileageRates();
      await controller.configuration();
      controller.fetchEmployeesID();
       setupCustomFieldValidation();
       loadAndAppendCashAdvanceList();
       initializeCashAdvanceSelection();
      _initializeData();
      if (widget.mileageId!.stepType == "Review") {
        controller.isEnable.value = true;
      } else {
        controller.isEnable.value = false;
      }
      if (widget.mileageId != null) {
        // controller.isEnable.value = false;
        historyFuture = controller.fetchExpenseHistory(widget.mileageId!.recId);

        // Pre-select vehicle type safely
        final matchingVehicle = controller.vehicleTypes.firstWhere(
          (vehicle) => vehicle.id == controller.mileageVehicleID.text,
          orElse: () => controller.vehicleTypes.first,
        );
        controller.selectedVehicleType = matchingVehicle;
        controller.mileageVehicleName.text = matchingVehicle.name;
      } else {
        controller.isEnable.value = true;
      }
    });

    if (widget.mileageId != null) {
      controller.tripControllers.clear();
      //  RxBool isEnable = false.obs;

      final expense = widget.mileageId!;
      final dateTime = DateTime.fromMillisecondsSinceEpoch(expense.receiptDate,isUtc: true);
      final formattedDate = DateFormat(controller.selectedFormat?.key ?? 'dd/MM/yyyy').format(dateTime);
      controller.expenseIdController.text = expense.expenseId;
      controller.employeeIdController.text = expense.employeeId;
      controller.employeeName.text = expense.employeeName;
      controller.expenseID = expense.expenseId;
      controller.recID = expense.recId ?? 0; // Use 0 as fallback if null
      // controller.workitemrecid = expense.workitemRecId!;
      controller.mileageVehicleName.text = expense.vehicalType ?? '';
      controller.projectIdController.text = expense.projectId;
      controller.mileageVehicleID.text = expense.mileageRateId;
      controller.mileagDateController.text = formattedDate;
      controller.calculatedAmountINR = expense.totalAmountReporting;
      // final matchingVehicle = controller.vehicleTypes.firstWhere(
      //   (vehicle) => vehicle.id == expense.mileageRateId,
      //   orElse: () => controller.vehicleTypes.first,
      // );
      // if (matchingVehicle != null) {
      //   controller.selectedVehicleType = matchingVehicle;
      //   controller.mileageVehicleName.text = matchingVehicle.name;
      //   controller.mileageVehicleID.text = matchingVehicle.id;
      // }
      print("controller.calculatedAmountINR${controller.recID}");
      // controller.mileageVehicleName.text = expense.vehicalType!;
      if (expense.travelPoints.isNotEmpty &&
          expense.travelPoints.first.fromLocation ==
              expense.travelPoints.last.toLocation) {
        controller.isRoundTrip = true;
      } else {
        controller.isRoundTrip = false;
      }
      if (expense.travelPoints.isNotEmpty) {
        // Check for round trip
        final firstFrom = expense.travelPoints.first.fromLocation;
        final lastTo = expense.travelPoints.last.toLocation;

        final travelPoints = expense.travelPoints;

        if (travelPoints.isNotEmpty) {
          final firstFrom = travelPoints.first.fromLocation;
          final lastTo = travelPoints.last.toLocation;

          if (firstFrom.isNotEmpty &&
              lastTo.isNotEmpty &&
              firstFrom == lastTo &&
              travelPoints.length > 1) {
            // ✅ Round trip detected: Merge into one Start-End pair
            controller.tripControllers.add(
              TextEditingController(text: firstFrom),
            );
            controller.tripControllers.add(
              TextEditingController(
                  text: travelPoints
                      .first.toLocation), // Destination of first trip
            );
            print("✅ Round trip detected. Only one Start-End pair created.");
          } else {
            // ❌ Not a perfect round trip: handle all legs without skipping stops
            final addedLocations =
                <String>{}; // Track unique locations to avoid duplicates

            for (int i = 0; i < travelPoints.length; i++) {
              final current = travelPoints[i];

              // Add FromLocation if not already added
              if (!addedLocations.contains(current.fromLocation)) {
                controller.tripControllers.add(
                  TextEditingController(text: current.fromLocation),
                );
                addedLocations.add(current.fromLocation);
              }

              // Add ToLocation if not already added
              if (!addedLocations.contains(current.toLocation)) {
                controller.tripControllers.add(
                  TextEditingController(text: current.toLocation),
                );
                addedLocations.add(current.toLocation);
              }
            }

            print("✅ Added all unique locations while preserving order.");
          }
        }
      }
    }
  }

  void setupCustomFieldValidation() {
    for (var field in controller.customFields) {
      if (field['ObjectName'] == 'ExpenseHeader' &&
          field['ExpenseType'] == 'Mileage') {
        final fieldKey = field['FieldName'];
        final textController = fieldControllers[fieldKey];
        if (textController != null) {
          textController.removeListener(_customFieldListener);
          textController.addListener(_customFieldListener);
        }
      }
    }
  }
void _customFieldListener() {
    for (var field in controller.customFields) {
      if (field['Error'] != null) {
        final value = field['EnteredValue'];
        if (value != null && value.toString().trim().isNotEmpty) {
          field['Error'] = null;
        }
      }
    }
    controller.customFields.refresh();
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

  void handleSubmit() {
    setState(() {
      projectError = null;
      vehicleError = null;
    });

    bool isValid = true;

    if (controller.projectIdController.text.isEmpty) {
      setState(() {
        projectError = 'Please select a Project';
      });
      isValid = false;
    }
    final projectMandatory = isFieldMandatory('Project Id');
    if (controller.projectIdController.text.isEmpty && projectMandatory) {
      _showProjectError = true;
      isValid = false;
    } else {
      _showProjectError = false;
    }
    if (controller.mileageVehicleID.text.isEmpty) {
      setState(() {
        vehicleError = 'Please select a Vehicle Type';
      });
      isValid = false;
    }
 final customFieldsValid = validateCustomFields();
   if (!customFieldsValid) {
  isValid = false;
  Fluttertoast.showToast(
    msg: "Please fill all required custom fields",
    backgroundColor: Colors.red[100],
    textColor: Colors.red[800],
  );
  scrollToFirstError(); // Optional: scroll to first error
  return; // Prevent navigation
}
    if (isValid) {
      // Call your submit logic
      // controller.submitMileage();
      // debugPrint("✅ mileageId received: ${widget.mileageId.toString()}");

      Navigator.pushNamed(context, AppRoutes.mileageExpense, arguments: {
        'isEditMode': true,
        'mileageId': widget.mileageId,
      });
      // Navigator.pushNamed(context, AppRoutes.mileageExpense);
    } else {
      // Optionally show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors above')),
      );
    }
  }
  // @override
  // void dispose() {
  //   controller.fromDateController.dispose();
  //   controller.toDateController.dispose();
  //   controller.locationController.dispose();
  //   controller.daysController.dispose();
  //   controller.perDiemController.dispose();
  //   controller.amountInController.dispose();
  //   controller.purposeController.dispose();
  //   super.dispose();
  // }
void scrollToFirstError() {
  for (int i = 0; i < controller.customFields.length; i++) {
    final field = controller.customFields[i];
    if (field['Error'] != null && mounted) {
      // You can use a ScrollController to scroll to the error field
      // For now, just show a toast
      Fluttertoast.showToast(
        msg: "Please fix errors in the form",
        backgroundColor: Colors.red[100],
        textColor: Colors.red[800],
      );
      break;
    }
  }
}
  String getCustomFieldDisplayValue(Map<String, dynamic> field) {
    final fieldType = field['FieldType']?.toString().toLowerCase();
    final value = field['EnteredValue'];

    if (value == null) return '';

    switch (fieldType) {
      case 'date':
        if (value is DateTime) {
          return DateFormat('dd/MM/yyyy').format(value);
        }
        return value.toString();

      case 'date&time':
        if (value is DateTime) {
          return DateFormat('dd/MM/yyyy hh:mm a').format(value);
        }
        return value.toString();

      case 'integer':
      case 'longinteger':
        if (value is int) {
          return value.toString();
        }
        return value.toString();

      case 'decimal':
      case 'amount':
      case 'percent':
      case 'percentage':
        if (value is double) {
          return value.toStringAsFixed(
            value.truncateToDouble() == value ? 0 : 2,
          );
        }
        return value.toString();

      case 'checkbox':
        return (value is bool && value) ? 'true' : 'false';

      default:
        return value.toString();
    }
  }
  bool validateCustomFields() {
  bool isValid = true;

  for (var field in controller.customFields) {
    // Only validate ExpenseHeader fields with Mileage type
    if (field['ObjectName'] != 'ExpenseHeader' ||
        field['ExpenseType'] != 'Mileage') {
      continue;
    }

    final fieldType = field['FieldType']?.toString().toLowerCase();
    final isMandatory = field['IsMandatory'] == true;
    final fieldName = field['FieldLabel'] ?? field['FieldName'] ?? '';

    String? error;

    if (isMandatory) {
      switch (fieldType) {
        case 'list':
        case 'customlist':
        case 'systemlist':
          final selectedValue = field['SelectedValue'];
          if (selectedValue == null) {
            error = '$fieldName is required';
            isValid = false;
          }
          break;

        case 'checkbox':
          final value = field['EnteredValue'] ?? false;
          if (value != true) {  // ✅ Check if checkbox is not checked
            error = '$fieldName is required';
            isValid = false;
          }
          break;

        case 'date':
        case 'date&time':
          final value = field['EnteredValue'];
          if (value == null) {
            error = '$fieldName is required';
            isValid = false;
          }
          break;

        case 'integer':
        case 'longinteger':
          final value = field['EnteredValue'];
          // ✅ Also check if value is null for mandatory fields
          if (value == null || (value is int && value == 0)) {
            error = '$fieldName is required';
            isValid = false;
          }
          break;

        case 'decimal':
        case 'amount':
        case 'percent':
        case 'percentage':
          final value = field['EnteredValue'];
          // ✅ Check both null and zero for mandatory numeric fields
          if (value == null || (value is double && value == 0.0)) {
            error = '$fieldName is required';
            isValid = false;
          }
          break;

        case 'email':
          final value = field['EnteredValue']?.toString().trim() ?? '';
          if (value.isEmpty) {
            error = '$fieldName is required';
            isValid = false;
          } else {
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value)) {
              error = 'Please enter a valid email address';
              isValid = false;
            }
          }
          break;

        case 'mobilenumber':
          final value = field['EnteredValue']?.toString().trim() ?? '';
          if (value.isEmpty) {
            error = '$fieldName is required';
            isValid = false;
          } else {
            final phoneRegex = RegExp(r'^\+?[\d\s\-]{7,15}$');
            if (!phoneRegex.hasMatch(value)) {
              error = 'Please enter a valid mobile number';
              isValid = false;
            }
          }
          break;

        case 'url':
          final value = field['EnteredValue']?.toString().trim() ?? '';
          if (value.isEmpty) {
            error = '$fieldName is required';
            isValid = false;
          } else {
            final urlRegex = RegExp(
              r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
            );
            if (!urlRegex.hasMatch(value)) {
              error = 'Please enter a valid URL';
              isValid = false;
            }
          }
          break;

        default: // Text fields
          final value = field['EnteredValue']?.toString().trim() ?? '';
          if (value.isEmpty) {
            error = '$fieldName is required';
            isValid = false;
          }
          break;
      }
    } else {
      // Optional fields - still validate format if value is provided
      switch (fieldType) {
        case 'email':
          final value = field['EnteredValue']?.toString().trim() ?? '';
          if (value.isNotEmpty) {
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value)) {
              error = 'Please enter a valid email address';
              isValid = false;
            }
          }
          break;

        case 'mobilenumber':
          final value = field['EnteredValue']?.toString().trim() ?? '';
          if (value.isNotEmpty) {
            final phoneRegex = RegExp(r'^\+?[\d\s\-]{7,15}$');
            if (!phoneRegex.hasMatch(value)) {
              error = 'Please enter a valid mobile number';
              isValid = false;
            }
          }
          break;

        case 'url':
          final value = field['EnteredValue']?.toString().trim() ?? '';
          if (value.isNotEmpty) {
            final urlRegex = RegExp(
              r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
            );
            if (!urlRegex.hasMatch(value)) {
              error = 'Please enter a valid URL';
              isValid = false;
            }
          }
          break;
      }
    }

    field['Error'] = error;
  }

  controller.customFields.refresh();
  return isValid;
}

  Future<void> _loadSettings() async {
    final settings = await controller.fetchGeneralSettings();
    if (settings != null) {
      setState(() {
        allowMultSelect = settings.allowMultipleCashAdvancesPerExpenseReg;
        print("allowDocAttachments$allowMultSelect");
        // isLoading = false;
      });
    } else {
      // setState(() => isLoading = false);
    }
  }
  void handleSave() {
    // Save logic here
    print("Save clicked");
  }
 Future<void> _initializeData() async {
    await loadAndAppendCashAdvanceList();
    initializeCashAdvanceSelection();
  }

  void initializeCashAdvanceSelection() {
    String? backendSelectedIds = controller.cashAdvReqIds;
    print("controller.cashAdvReqIds$backendSelectedIds");
    controller.preloadCashAdvanceSelections(
      controller.cashAdvanceListDropDown,
      backendSelectedIds,
    );
  }
    Future<void> loadAndAppendCashAdvanceList() async {
    controller.cashAdvanceListDropDown.clear();
    try {
      final newItems = await controller.fetchExpenseCashAdvanceList();

      final existingIds = controller.cashAdvanceListDropDown
          .map((e) => e.cashAdvanceReqId)
          .toSet();

      final uniqueNewItems = newItems.where(
        (item) => !existingIds.contains(item.cashAdvanceReqId),
      );

      controller.cashAdvanceListDropDown.addAll(uniqueNewItems);

      print(
        "✅ Updated cashAdvanceListDropDown: ${controller.cashAdvanceListDropDown.length}",
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
    print("controller.calculatedAmountINR1");

    return WillPopScope(onWillPop: () async {
       controller.clearFormFields();
        controller.clearFormFieldsPerdiem();
          controller.resetFieldsMileage();
         controller.clearFormFieldsPerdiem();
      Navigator.pop(context);
      return true; // allow back navigation
    }, child: Scaffold(body: Obx(() {
      return controller.isLoadingGE2.value
          ? const SkeletonLoaderPage()
          : Column(
              children: [
                // const SizedBox(height: 40),
                Expanded(
                  child: Container(
                    // height: 300,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      // color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.mileageDetails,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          if (widget.mileageId != null)
                            buildTextField(
                                "${AppLocalizations.of(context)!.expenseId}*",
                                controller.expenseIdController,
                                false),
                          if (widget.mileageId != null)
                            buildTextField(
                                "${AppLocalizations.of(context)!.employeeId} *",
                                controller.employeeIdController,
                                false),
                                if (widget.mileageId != null)
                                   buildTextField(
                            "${AppLocalizations.of(context)!.employeeName} *",
                            controller.employeeName,
                             false,
                          ),
                          buildDateField(
                              "${AppLocalizations.of(context)!.mileageDate} *",
                              controller.mileagDateController),
                          // Project Dropdown

                          // SearchableMultiColumnDropdownField<Project>(
                          //   labelText: 'Project *',
                          //   enabled: controller.isEnable.value,
                          //   columnHeaders: const [
                          //     'Project Name',
                          //     'Project Id'
                          //   ],
                          //   items: controller.project,
                          //   selectedValue: controller.selectedProject,
                          //   searchValue: (proj) =>
                          //       '${proj.name} ${proj.code}',
                          //   displayText: (proj) => proj.code,
                          //   onChanged: (proj) {
                          //     setState(() {
                          //       controller.selectedProject = proj;
                          //       controller.projectIdController.text =
                          //           proj!.code;
                          //       projectError =
                          //           null; // Clear error when user selects
                          //     });
                          //     controller.fetchExpenseCategory();
                          //   },
                          //   controller: controller.projectIdController,
                          //   rowBuilder: (proj, searchQuery) {
                          //     return Padding(
                          //       padding: const EdgeInsets.symmetric(
                          //           vertical: 12, horizontal: 16),
                          //       child: Row(
                          //         children: [
                          //           Expanded(child: Text(proj.name)),
                          //           Expanded(child: Text(proj.code)),
                          //         ],
                          //       ),
                          //     );
                          //   },
                          // ),
                          // if (projectError != null)
                          //   Padding(
                          //     padding: const EdgeInsets.only(
                          //         top: 4, left: 12),
                          //     child: Text(
                          //       projectError!,
                          //       style: const TextStyle(
                          //           color: Colors.red, fontSize: 12),
                          //     ),
                          //   ),


                             Obx(() {
                                return Column(
                                  children: controller.customFields
                                      .where(
                                        (field) =>
                                            field['ObjectName'] ==
                                                'ExpenseHeader' &&
                                            field['ExpenseType'] == 'Mileage',
                                      )
                                      .map((field) {
                                        final String label =
                                            field['FieldLabel'] ??
                                            field['FieldName'];
                                        final bool isMandatory =
                                            field['IsMandatory'] ?? false;
                                        final String fieldKey =
                                            field['FieldName'];
                                        final String fieldType =
                                            field['FieldType'] ?? 'Text';
                                        final bool isDateTime =
                                            fieldType == 'Date&Time';

                                        if (!fieldControllers.containsKey(
                                          fieldKey,
                                        )) {
                                          fieldControllers[fieldKey] =
                                              TextEditingController();
                                        }

                                        Widget inputField;

                                        if (fieldType == 'List' ||
                                            fieldType == 'CustomList' ||
                                            fieldType == 'SystemList') {
                                          if (field['_rxSelectedValue'] ==
                                              null) {
                                            field['_rxSelectedValue'] =
                                                Rx<CustomDropdownValue?>(
                                                  field['SelectedValue']
                                                      as CustomDropdownValue?,
                                                );
                                          }

                                          inputField = Obx(() {
                                            final rxValue =
                                                field['_rxSelectedValue']
                                                    as Rx<CustomDropdownValue?>;
                                            return SearchableMultiColumnDropdownField<
                                              CustomDropdownValue
                                            >(
                                              labelText:
                                                  '$label${isMandatory ? " *" : ""}',
                                              items:
                                                  (field['Options']
                                                      as List<
                                                        CustomDropdownValue
                                                      >?) ??
                                                  [],
                                              selectedValue: rxValue.value,
                                              searchValue: (val) =>
                                                  val.valueName,
                                              enabled:
                                                  controller.isEnable.value,
                                              displayText: (val) =>
                                                  val.valueName,
                                              columnHeaders: const [
                                                'Value ID',
                                                'Value Name',
                                              ],
                                              rowBuilder: (val, searchQuery) =>
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 10,
                                                          horizontal: 16,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            val.valueId,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            val.valueName,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              onChanged: (val) {
                                                rxValue.value = val;
                                                field['SelectedValue'] = val;
                                                field['Error'] = null;
                                              },
                                            );
                                          });
                                        } else if (fieldType == 'Checkbox') {
                                          if (field['_rxCheckboxValue'] ==
                                              null) {
                                            field['_rxCheckboxValue'] =
                                                Rx<bool>(
                                                  field['EnteredValue'] ??
                                                      false,
                                                );
                                          }

                                          inputField = Obx(() {
                                            final rxValue =
                                                field['_rxCheckboxValue']
                                                    as Rx<bool>;
                                            return CheckboxListTile(
                                              title: Text(
                                                '$label${isMandatory ? " *" : ""}',
                                              ),
                                              value: rxValue.value,
                                              enabled:
                                                  controller.isEnable.value,
                                              controlAffinity:
                                                  ListTileControlAffinity
                                                      .leading,
                                              contentPadding: EdgeInsets.zero,
                                              onChanged:
                                                  controller.isEnable.value
                                                  ? (bool? val) {
                                                      rxValue.value =
                                                          val ?? false;
                                                      field['EnteredValue'] =
                                                          val ?? false;
                                                      field['Error'] = null;
                                                    }
                                                  : null,
                                            );
                                          });
                                        } else if (fieldType == 'Date' ||
                                            fieldType == 'Date&Time') {
                                          if (field['_rxDateValue'] == null) {
                                            field['_rxDateValue'] =
                                                Rx<DateTime?>(
                                                  field['EnteredValue']
                                                      as DateTime?,
                                                );
                                          }

                                          inputField = Obx(() {
                                            final rxDateValue =
                                                field['_rxDateValue']
                                                    as Rx<DateTime?>;
                                            final currentDate =
                                                rxDateValue.value;

                                            if (currentDate != null) {
                                              if (isDateTime) {
                                                fieldControllers[fieldKey]!
                                                    .text = DateFormat(
                                                  'dd/MM/yyyy hh:mm a',
                                                ).format(currentDate);
                                              } else {
                                                fieldControllers[fieldKey]!
                                                    .text = DateFormat(
                                                  'dd/MM/yyyy',
                                                ).format(currentDate);
                                              }
                                            } else {
                                              fieldControllers[fieldKey]!.text =
                                                  '';
                                            }

                                            return TextFormField(
                                              enabled:
                                                  controller.isEnable.value,
                                              readOnly: true,
                                              controller:
                                                  fieldControllers[fieldKey],
                                              decoration: InputDecoration(
                                                labelText:
                                                    '$label${isMandatory ? " *" : ""}',
                                                border:
                                                    const OutlineInputBorder(),
                                                errorText: field['Error'],
                                                suffixIcon: const Icon(
                                                  Icons.calendar_today,
                                                ),
                                              ),
                                              onTap: controller.isEnable.value
                                                  ? () async {
                                                      DateTime? currentDate =
                                                          rxDateValue.value ??
                                                          DateTime.now();

                                                      final DateTime?
                                                      pickedDate =
                                                          await showDatePicker(
                                                            context: context,
                                                            initialDate:
                                                                currentDate,
                                                            firstDate: DateTime(
                                                              2000,
                                                            ),
                                                            lastDate: DateTime(
                                                              2100,
                                                            ),
                                                          );

                                                      if (pickedDate == null)
                                                        return;

                                                      if (isDateTime) {
                                                        TimeOfDay initialTime =
                                                            TimeOfDay.now();
                                                        if (rxDateValue.value !=
                                                            null) {
                                                          initialTime =
                                                              TimeOfDay.fromDateTime(
                                                                rxDateValue
                                                                    .value!,
                                                              );
                                                        }

                                                        final TimeOfDay?
                                                        pickedTime =
                                                            await showTimePicker(
                                                              context: context,
                                                              initialTime:
                                                                  initialTime,
                                                            );

                                                        if (pickedTime == null)
                                                          return;

                                                        final fullDateTime =
                                                            DateTime(
                                                              pickedDate.year,
                                                              pickedDate.month,
                                                              pickedDate.day,
                                                              pickedTime.hour,
                                                              pickedTime.minute,
                                                            );

                                                        rxDateValue.value =
                                                            fullDateTime;
                                                        field['EnteredValue'] =
                                                            fullDateTime;
                                                      } else {
                                                        rxDateValue.value =
                                                            pickedDate;
                                                        field['EnteredValue'] =
                                                            pickedDate;
                                                      }

                                                      field['Error'] = null;
                                                    }
                                                  : null,
                                              validator: (value) {
                                                if (isMandatory &&
                                                    rxDateValue.value == null) {
                                                  return '$label is required';
                                                }
                                                return null;
                                              },
                                            );
                                          });
                                        } else if (fieldType == 'LongInteger') {
                                          if (field['_rxIntValue'] == null) {
                                            field['_rxIntValue'] = Rx<int?>(
                                              field['EnteredValue'] as int?,
                                            );
                                          }

                                          inputField = Obx(() {
                                            final rxValue =
                                                field['_rxIntValue']
                                                    as Rx<int?>;

                                            final newText =
                                                rxValue.value?.toString() ?? '';
                                            if (fieldControllers[fieldKey]!
                                                    .text !=
                                                newText) {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                    fieldControllers[fieldKey]!
                                                            .text =
                                                        newText;
                                                  });
                                            }

                                            return TextFormField(
                                              enabled:
                                                  controller.isEnable.value,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              controller:
                                                  fieldControllers[fieldKey],
                                              decoration: InputDecoration(
                                                labelText:
                                                    '$label${isMandatory ? " *" : ""}',
                                                border:
                                                    const OutlineInputBorder(),
                                                errorText: field['Error'],
                                              ),
                                              onChanged: (value) {
                                                final intValue = int.tryParse(
                                                  value,
                                                );
                                                rxValue.value = intValue;
                                                field['EnteredValue'] =
                                                    intValue;
                                                field['Error'] = null;
                                              },
                                              validator: (value) {
                                                if (isMandatory &&
                                                    (value == null ||
                                                        value.trim().isEmpty)) {
                                                  return '$label is required';
                                                }
                                                return null;
                                              },
                                            );
                                          });
                                        } else if (fieldType == 'Decimal') {
                                          if (field['_rxDoubleValue'] == null) {
                                            field['_rxDoubleValue'] =
                                                Rx<double?>(
                                                  field['EnteredValue']
                                                      as double?,
                                                );
                                          }

                                          inputField = Obx(() {
                                            final rxValue =
                                                field['_rxDoubleValue']
                                                    as Rx<double?>;

                                            final newText =
                                                rxValue.value?.toString() ?? '';
                                            if (fieldControllers[fieldKey]!
                                                    .text !=
                                                newText) {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                    fieldControllers[fieldKey]!
                                                            .text =
                                                        newText;
                                                  });
                                            }

                                            return TextFormField(
                                              enabled:
                                                  controller.isEnable.value,
                                              keyboardType:
                                                  const TextInputType.numberWithOptions(
                                                    decimal: true,
                                                  ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(
                                                  RegExp(r'^\d+\.?\d*'),
                                                ),
                                              ],
                                              controller:
                                                  fieldControllers[fieldKey],
                                              decoration: InputDecoration(
                                                labelText:
                                                    '$label${isMandatory ? " *" : ""}',
                                                border:
                                                    const OutlineInputBorder(),
                                                errorText: field['Error'],
                                              ),
                                              onChanged: (value) {
                                                final doubleValue =
                                                    double.tryParse(value);
                                                rxValue.value = doubleValue;
                                                field['EnteredValue'] =
                                                    doubleValue;
                                                field['Error'] = null;
                                              },
                                              validator: (value) {
                                                if (isMandatory &&
                                                    (value == null ||
                                                        value.trim().isEmpty)) {
                                                  return '$label is required';
                                                }
                                                return null;
                                              },
                                            );
                                          });
                                        } else if (fieldType == 'Email') {
                                          if (field['_rxStringValue'] == null) {
                                            field['_rxStringValue'] =
                                                Rx<String?>(
                                                  field['EnteredValue']
                                                      as String?,
                                                );
                                          }

                                          inputField = Obx(() {
                                            final rxValue =
                                                field['_rxStringValue']
                                                    as Rx<String?>;

                                            final newText = rxValue.value ?? '';
                                            if (fieldControllers[fieldKey]!
                                                    .text !=
                                                newText) {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                    fieldControllers[fieldKey]!
                                                            .text =
                                                        newText;
                                                  });
                                            }

                                            return TextFormField(
                                              enabled:
                                                  controller.isEnable.value,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              controller:
                                                  fieldControllers[fieldKey],
                                              decoration: InputDecoration(
                                                labelText:
                                                    '$label${isMandatory ? " *" : ""}',
                                                border:
                                                    const OutlineInputBorder(),
                                                errorText: field['Error'],
                                                suffixIcon: const Icon(
                                                  Icons.email_outlined,
                                                ),
                                              ),
                                              onChanged: (value) {
                                                rxValue.value = value;
                                                field['EnteredValue'] = value;
                                                field['Error'] = null;
                                              },
                                              validator: (value) {
                                                if (isMandatory &&
                                                    (value == null ||
                                                        value.trim().isEmpty)) {
                                                  return '$label is required';
                                                }
                                                if (value != null &&
                                                    value.isNotEmpty) {
                                                  final emailRegex = RegExp(
                                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                                  );
                                                  if (!emailRegex.hasMatch(
                                                    value,
                                                  )) {
                                                    return 'Enter a valid email address';
                                                  }
                                                }
                                                return null;
                                              },
                                            );
                                          });
                                        } else if (fieldType ==
                                            'MobileNumber') {
                                          if (field['_rxStringValue'] == null ||
                                              field['_rxStringValue']
                                                  is! Rx<String?>) {
                                            field['_rxStringValue'] =
                                                Rx<String?>(
                                                  field['EnteredValue']
                                                      ?.toString(),
                                                );
                                          }

                                          inputField = Obx(() {
                                            final Rx<String?> rxValue =
                                                field['_rxStringValue']
                                                    as Rx<String?>;

                                            final newText = rxValue.value ?? '';

                                            if (fieldControllers[fieldKey]!
                                                    .text !=
                                                newText) {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                    if (fieldControllers
                                                        .containsKey(
                                                          fieldKey,
                                                        )) {
                                                      fieldControllers[fieldKey]!
                                                              .text =
                                                          newText;
                                                    }
                                                  });
                                            }

                                            return TextFormField(
                                              enabled:
                                                  controller.isEnable.value,
                                              keyboardType: TextInputType.phone,
                                              controller:
                                                  fieldControllers[fieldKey],
                                              decoration: InputDecoration(
                                                labelText:
                                                    '$label${isMandatory ? " *" : ""}',
                                                border:
                                                    const OutlineInputBorder(),
                                                errorText: field['Error'],
                                                suffixIcon: const Icon(
                                                  Icons.phone_outlined,
                                                ),
                                              ),
                                              onChanged: (value) {
                                                rxValue.value = value;
                                                field['EnteredValue'] = value;
                                                field['Error'] = null;
                                              },
                                              validator: (value) {
                                                if (isMandatory &&
                                                    (value == null ||
                                                        value.trim().isEmpty)) {
                                                  return '$label is required';
                                                }

                                                if (value != null &&
                                                    value.isNotEmpty) {
                                                  final phoneRegex = RegExp(
                                                    r'^\+?[\d\s\-]{7,15}$',
                                                  );

                                                  if (!phoneRegex.hasMatch(
                                                    value,
                                                  )) {
                                                    return 'Enter a valid mobile number';
                                                  }
                                                }

                                                return null;
                                              },
                                            );
                                          });
                                        } else {
                                          if (field['_rxStringValue'] == null ||
                                              field['_rxStringValue']
                                                  is! Rx<String?>) {
                                            field['_rxStringValue'] =
                                                Rx<String?>(
                                                  field['EnteredValue']
                                                      ?.toString(),
                                                );
                                          }

                                          inputField = Obx(() {
                                            final Rx<String?> rxValue =
                                                field['_rxStringValue']
                                                    as Rx<String?>;

                                            final newText = rxValue.value ?? '';

                                            if (fieldControllers[fieldKey]!
                                                    .text !=
                                                newText) {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                    if (fieldControllers
                                                        .containsKey(
                                                          fieldKey,
                                                        )) {
                                                      fieldControllers[fieldKey]!
                                                              .text =
                                                          newText;
                                                    }
                                                  });
                                            }

                                            return TextFormField(
                                              enabled:
                                                  controller.isEnable.value,
                                              keyboardType: TextInputType.text,
                                              controller:
                                                  fieldControllers[fieldKey],
                                              decoration: InputDecoration(
                                                labelText:
                                                    '$label${isMandatory ? " *" : ""}',
                                                border:
                                                    const OutlineInputBorder(),
                                                errorText: field['Error'],
                                              ),
                                              onChanged: (value) {
                                                rxValue.value = value;
                                                field['EnteredValue'] = value;
                                                field['Error'] = null;
                                              },
                                              validator: (value) {
                                                if (isMandatory &&
                                                    (value == null ||
                                                        value.trim().isEmpty)) {
                                                  return '$label is required';
                                                }
                                                return null;
                                              },
                                            );
                                          });
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: inputField,
                                        );
                                      })
                                      .toList(),
                                );
                              }),
                          ...controller.configList
                              .where((field) =>
                                  field['FieldName'] == 'Project Id' &&
                                  field['IsEnabled'] == true) // 👈 filter only Project Id
                              .map((field) {
                            final String label = field['FieldName'];
                            final bool isMandatory =
                                field['IsMandatory'];


                            Widget inputField;

                            // Project dropdown logic
                            inputField = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SearchableMultiColumnDropdownField<Project>(
                                  labelText:
                                      '${AppLocalizations.of(context)!.projectId} ${isMandatory ? "*" : ""}',
                                  columnHeaders: [
                                    AppLocalizations.of(context)!.projectName,
                                    AppLocalizations.of(context)!.projectId
                                  ],
                                  enabled: controller.isEnable.value,
                                  controller: controller.projectIdController,
                                  items: controller.project,
                                  selectedValue: controller.selectedProject,
                                  searchValue: (proj) =>
                                      '${proj.name} ${proj.code}',
                                  displayText: (proj) => proj.code,
                                  onChanged: (proj) {
                                    setState(() {
                                      controller.selectedProject = proj;
                                      controller.projectIdController.text =
                                          proj!.code;
                                      if (proj != null) {
                                        _showProjectError = false;
                                      }
                                    });
                                    // controller.fetchExpenseCategory();
                                  },
                                  rowBuilder: (proj, searchQuery) {

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                      child: Row(
                                        children: [
                                          SizedBox(width: 10,),
                                          Expanded(child: Text(proj.name)),
                                          Expanded(child: Text(proj.code)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                if (_showProjectError)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .pleaseSelectProject,
                                      style: const TextStyle(
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
                          // const SizedBox(height: 10),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MultiSelectMultiColumnDropdownField<
                                    CashAdvanceDropDownModel>(
                                  labelText: AppLocalizations.of(context)!
                                      .cashAdvanceRequest,
                                  items: controller.cashAdvanceListDropDown,
                                  isMultiSelect: allowMultSelect ?? false,
                                  selectedValue: controller.singleSelectedItem,
                                  selectedValues: controller.multiSelectedItems,
                                   controller: controller
                                              .cashAdvanceIds,
                                  enabled: controller.isEnable.value,
                                  searchValue: (proj) => proj.cashAdvanceReqId,
                                  displayText: (proj) => proj.cashAdvanceReqId,
                                  validator: (proj) => proj == null
                                      ? AppLocalizations.of(context)!
                                          .pleaseSelectCashAdvanceField
                                      : null,
                                  onChanged: (item) {
                                    controller.singleSelectedItem =
                                        item; // ✅ update selected item
                                  },
                                  onMultiChanged: (items) {
                                    controller.multiSelectedItems
                                        .assignAll(items); // ✅ update list
                                  },
                                  columnHeaders: [
                                    AppLocalizations.of(context)!.requestId,
                                    AppLocalizations.of(context)!.requestDate
                                  ],
                                  rowBuilder: (proj, searchQuery) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child:
                                                  Text(proj.cashAdvanceReqId)),
                                          Expanded(
                                              child: Text(
                                                  proj.requestDate.toString())),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ]),
                          const SizedBox(height: 14),
                          // Vehicle Type Dropdown
                          SearchableMultiColumnDropdownField<VehicleType>(
                            labelText:
                                '${AppLocalizations.of(context)!.mileageType} *',
                            enabled: controller.isEnable.value,
                            columnHeaders: const [
                              'ID',
                            ],
                            items: controller.vehicleTypes,
                            selectedValue: controller.selectedVehicleType,
                            searchValue: (vehicle) =>
                                '${vehicle.name} ${vehicle.mileageRateLines.first.mileageRate}',
                            displayText: (vehicle) => vehicle.id,
                            onChanged: (vehicle) {
                              setState(() {
                                controller.selectedVehicleType = vehicle!;
                                controller.mileageVehicleName.text =
                                    vehicle.name;
                                controller.mileageVehicleID.text = vehicle.id;
                                vehicleError = null; // Clear error
                              });
                              controller.calculateAmount();
                            },
                            controller: controller.mileageVehicleID,
                            rowBuilder: (vehicle, searchQuery) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(vehicle.id)),
                                  ],
                                ),
                              );
                            },
                          ),
                          if (vehicleError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 12),
                              child: Text(
                                vehicleError!,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 12),
                              ),
                            ),
                          const SizedBox(height: 14),
                          // if (widget.mileageId != null)
                          buildTextField(
                              "Vehicle ", controller.mileageVehicleName, false),
                          const SizedBox(height: 24),
                          if (widget.mileageId != null)
                            _buildSection(
                              title:
                                  AppLocalizations.of(context)!.trackingHistory,
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
                    return Center(child: Text("No Data Available Please Skip Next"));
                  }

                                    final historyList = snapshot.data!;
                                    if (historyList.isEmpty) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .noHistoryMessage,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          ),
                                        ),
                                      );
                                    }
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
                             SizedBox(height: 83,),
                          // ElevatedButton(
                          //   onPressed: handleSubmit,
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: AppColors.gradientEnd,
                          //     padding: const EdgeInsets.symmetric(vertical: 14),
                          //     shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(30)),
                          //     minimumSize: const Size(double.infinity, 50),
                          //   ),
                          //   child: Text(
                          //     AppLocalizations.of(context)!.next,
                          //     style: const TextStyle(
                          //         fontSize: 16, color: Colors.white),
                          //   ),
                          // ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
    })));
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
                    '${AppLocalizations.of(context)!.submittedOn}${DateFormat(controller.selectedFormat?.key ?? 'dd/MM/yyyy').format(item.createdDate)}',
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
            // backgroundColor: Colors.white,
            // collapsedBackgroundColor: Colors.white,
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

  Widget buildTextField(
      String label, TextEditingController controller, bool? bool,
      {int maxLines = 1, Widget? suffix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        enabled: bool,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          suffixIcon: suffix,
          filled: true,
          
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          // contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget buildDateField(String label, TextEditingController controllers) {
    return buildTextField(
      label,
      controllers,
      controller.isEnable.value,
      suffix: IconButton(
        icon: const Icon(Icons.calendar_today),
        onPressed: () async {
          // 🟢 Set initialDate based on controllers.text or fallback to now
          DateTime initialDate = DateTime.now();
          if (controllers.text.isNotEmpty) {
            try {
              initialDate =
                  DateFormat(controller.selectedFormat?.key ?? 'dd/MM/yyyy') // <-- Match your text format
                      .parseStrict(controllers.text.trim());
            } catch (e) {
              print("Invalid date in controllers.text: ${controllers.text}");
              initialDate = DateTime.now(); // fallback
            }
          }

          final picked = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
          );

          if (picked != null) {
            controller.selectedDateMileage = picked;
            controllers.text = DateFormat(controller.selectedFormat?.key ?? 'dd/MM/yyyy').format(picked);
            controller.fetchMileageRates();
            controller.selectedDate = picked;
            controller.fetchProjectName();
             loadAndAppendCashAdvanceList();
          }
        },
      ),
    );
  }

  Widget buildDropdownField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: selectedProject.isEmpty ? null : selectedProject,
        onChanged: (value) {
          setState(() {
            selectedProject = value ?? '';
          });
        },
        items: projectList
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          filled: true,
         
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}
