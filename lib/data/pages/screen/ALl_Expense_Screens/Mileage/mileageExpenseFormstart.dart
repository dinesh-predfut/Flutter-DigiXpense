import 'package:diginexa/core/comman/widgets/pageLoaders.dart';
import 'package:diginexa/core/comman/widgets/permissionHelper.dart';
import 'package:diginexa/core/comman/widgets/searchDropown.dart';
import 'package:diginexa/core/constant/Parames/colors.dart';
import 'package:diginexa/data/models.dart';
import 'package:diginexa/data/pages/screen/widget/router/router.dart';
import 'package:diginexa/data/service.dart';
import 'package:diginexa/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import '../../../../../core/comman/widgets/multiselectDropdown.dart';
import '../../../../../core/utils.dart';

class MileageFirstFrom extends StatefulWidget {
  final bool isReadOnly;
  final ExpenseModelMileage? mileageId;
  const MileageFirstFrom({super.key, this.mileageId, required this.isReadOnly});

  @override
  State<MileageFirstFrom> createState() => _MileageFirstFromState();
}

class _MileageFirstFromState extends State<MileageFirstFrom>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<Controller>();
  final Map<String, TextEditingController> fieldControllers = {};

  Future<List<ExpenseHistory>>? historyFuture;
  String? statusApproval;
  bool _showProjectError = false;
  bool allowMultSelect = false;
  bool allowCashAd = false;
  String selectedProject = '';
  String? projectError;
  String? expenseIdError;
  String? employeeError;
  String? vehicleError;
  String expenseId = '';
  String employeeId = '';
  final List<String> projectList = ['Project A', 'Project B', 'Project C'];

  @override
  void initState() {
    super.initState();
    print("mileageId${widget.mileageId}");
    // Get today's date in organization's timezone
    final todayOrg = todayInOrgTimezone();
    final fromMs = toStartOfDayUtc(todayOrg);

    // Store as UTC DateTime
    controller.selectedDateMileage ??= DateTime.fromMillisecondsSinceEpoch(
      fromMs,
      isUtc: true,
    );

    // Format for display (converts UTC to org-local timezone)
    final formattedDate = formatDate(controller.selectedDateMileage!);
    controller.mileagDateController.text = formattedDate;
    controller.selectedDate = controller.selectedDateMileage;

    // Delay your logic safely
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      
      await controller.fetchProjectName();
      await controller.loadSequenceModules();
      await controller.configuration();
      controller.fetchEmployeesID();
      _loadSettings();
      loadAndAppendCashAdvanceList();
      initializeCashAdvanceSelection();
      setupCustomFieldValidation(); // ✅ Add validation listeners
controller.loadAllMillageCategotyCustomFieldValues(
        savedValues: [],
      );
      if (widget.mileageId != null) {
        controller.isEnable.value = false;
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

      final expense = widget.mileageId!;
      final dateTimeUtc = DateTime.fromMillisecondsSinceEpoch(
  expense.receiptDate,
  isUtc: true,
);
     final formattedDate = formatDate(dateTimeUtc);
      controller.expenseIdController.text = expense.expenseId;
      controller.employeeDropDownController.text = expense.employeeId;
      controller.employeeName.text = expense.employeeName;
      controller.accountingDistributions =
          expense.accountingDistributions ?? [];
      controller.expenseID = expense.expenseId;
      controller.cashAdvReqIds = expense.cashAdvReqId;
      statusApproval = expense.approvalStatus;
      controller.recID = expense.recId ?? 0;
      controller.projectIdController.text = expense.projectId;
      controller.mileageVehicleID.text = expense.mileageRateId;
      controller.mileagDateController.text = formattedDate;
      controller.calculatedAmountINR = expense.totalAmountReporting;

      print("controller.calculatedAmountINR${controller.recID}");
controller.fetchMileageRates();
      if (expense.travelPoints.isNotEmpty &&
          expense.travelPoints.first.fromLocation ==
              expense.travelPoints.last.toLocation) {
        controller.isRoundTrip = true;
      } else {
        controller.isRoundTrip = false;
      }

      if (expense.travelPoints.isNotEmpty) {
        final travelPoints = expense.travelPoints;

        if (travelPoints.isNotEmpty) {
          final firstFrom = travelPoints.first.fromLocation;
          final lastTo = travelPoints.last.toLocation;

          if (firstFrom.isNotEmpty &&
              lastTo.isNotEmpty &&
              firstFrom == lastTo &&
              travelPoints.length > 1) {
            controller.tripControllers.add(
              TextEditingController(text: firstFrom),
            );
            controller.tripControllers.add(
              TextEditingController(text: travelPoints.first.toLocation),
            );
            print("✅ Round trip detected. Only one Start-End pair created.");
          } else {
            final addedLocations = <String>{};

            for (int i = 0; i < travelPoints.length; i++) {
              final current = travelPoints[i];

              if (!addedLocations.contains(current.fromLocation)) {
                controller.tripControllers.add(
                  TextEditingController(text: current.fromLocation),
                );
                addedLocations.add(current.fromLocation);
              }

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

  void initializeCashAdvanceSelection() {
    String? backendSelectedIds = controller.cashAdvReqIds;
    print("preloadCashAdvanceSelections$backendSelectedIds");
    controller.preloadCashAdvanceSelections(
      controller.cashAdvanceListDropDown,
      backendSelectedIds,
    );
  }

  Future<void> loadAndAppendCashAdvanceList() async {
    controller.cashAdvanceListDropDown.clear();
    try {
      final newItems = await controller.fetchExpenseCashAdvanceList();
      controller.cashAdvanceListDropDown.addAll(newItems);
      print("cashAdvanceListDropDown${controller.cashAdvanceListDropDown}");
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> _loadSettings() async {
    final settings = await controller.fetchGeneralSettings();
    if (settings != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            allowMultSelect = settings.allowMultipleCashAdvancesPerExpenseReg;
            allowCashAd = settings.allowCashAdvAgainstExpenseReg;
          });
        }
      });
    }
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

  void handleSubmit() {
    setState(() {
      projectError = null;
      vehicleError = null;
      expenseIdError = null;
      employeeError = null;
    });

    bool isValid = true;
    final hideField = controller.hasModule("Expense");

    if (!hideField) {
      if (controller.expenseIdController.text.trim().isEmpty) {
        setState(() {
          expenseIdError = AppLocalizations.of(context)!.fieldRequired;
        });
        isValid = false;
      } else {
        setState(() {
          expenseIdError = null;
        });
      }
    }

    if (controller.employeeDropDownController.text.trim().isEmpty) {
      setState(() {
        employeeError = AppLocalizations.of(context)!.fieldRequired;
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
        vehicleError = AppLocalizations.of(context)!.fieldRequired;
      });
      isValid = false;
    }

    // ✅ Validate custom fields
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
      debugPrint("✅ mileageId received: ${widget.isReadOnly}");
      employeeError = null;
      Navigator.pushNamed(
        context,
        AppRoutes.mileageExpense,
        arguments: {
          'isEditMode': widget.isReadOnly,
          'mileageId': widget.mileageId,
        },
      );
    }
  }
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
      case 'percent':
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

  void handleSave() {
    print("Save clicked");
  }

  @override
  void dispose() {
    for (var controller in fieldControllers.values) {
      controller.removeListener(_customFieldListener);
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("controller.calculatedAmountINR1");
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    print("themeCOlor$primaryColor");
    Color buttonColor;
    switch (statusApproval) {
      case 'Approved':
        buttonColor = Colors.green;
        break;
      case 'Rejected':
        buttonColor = Colors.red;
        break;
      case 'Pending':
        buttonColor = Colors.orange;
        break;
      case "Created":
        buttonColor = Colors.blue;
        break;
      default:
        buttonColor = Colors.grey;
    }
    return WillPopScope(
      onWillPop: () async {
        if (!controller.isEnable.value) {
          controller.resetFieldsMileage();
          controller.clearFormFieldsPerdiem();
          return true;
        }

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.exitForm),
            content: Text(AppLocalizations.of(context)!.exitWarning),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  AppLocalizations.of(context)!.ok,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );

        if (shouldExit ?? false) {
          controller.resetFieldsMileage();
          controller.clearFormFieldsPerdiem();
          Navigator.pop(context);
          return true;
        }

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          leading: const BackButton(color: Colors.white),
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.mileageRegistration,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            if (widget.mileageId != null &&
                widget.mileageId!.approvalStatus != "Cancelled" &&
                widget.mileageId!.approvalStatus != "Approved" &&
                (widget.mileageId!.approvalStatus != "Pending" ||
                    widget.mileageId!.stepType == "Review") &&
                PermissionHelper.canUpdate("Expense Registration"))
              IconButton(
                icon: Icon(
                  controller.isEnable.value
                      ? Icons.remove_red_eye
                      : Icons.edit_document,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    controller.isEnable.value = !controller.isEnable.value;
                  });
                },
              ),
          ],
        ),
        body: Obx(() {
          return controller.isLoadingGE2.value
              ? const SkeletonLoaderPage()
              : Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
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
                              if (widget.mileageId != null)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        debugPrint("Status: $statusApproval");
                                      },
                                      icon: const Icon(
                                        Icons.donut_large,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        statusApproval!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: buttonColor,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        minimumSize: const Size(0, 32),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ],
                                ),
                              Text(
                                AppLocalizations.of(context)!.mileageDetails,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (widget.mileageId == null) ...[
                                Obx(() {
                                  if (controller.isSequenceLoading.value) {
                                    return const SizedBox();
                                  }

                                  final bool isCreate =
                                      widget.mileageId == null;
                                  final bool hideField = controller.hasModule(
                                    "Expense",
                                  );
                                  print("hideField$hideField");
                                  print("isCreate$isCreate");
                                  if (hideField) {
                                    return const SizedBox.shrink();
                                  }

                                  return Column(
                                    children: [
                                      TextFormField(
                                        controller:
                                            controller.expenseIdController,
                                        decoration: InputDecoration(
                                          labelText:
                                              '${AppLocalizations.of(context)!.expenseId} *',
                                          errorText: expenseIdError,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  );
                                }),
                              ],

                              if (widget.mileageId != null)
                                buildTextField(
                                  AppLocalizations.of(context)!.expenseId,
                                  controller.expenseIdController,
                                  false,
                                ),

                              if (widget.mileageId != null)
                                buildTextField(
                                  "${AppLocalizations.of(context)!.employeeId} *",
                                  controller.employeeDropDownController,
                                  false,
                                ),
                              if (widget.mileageId != null)
                                buildTextField(
                                  "${AppLocalizations.of(context)!.employeeName} *",
                                  controller.employeeName,
                                  false,
                                ),
                              buildDateField(
                                "${AppLocalizations.of(context)!.mileageDate} *",
                                controller.mileagDateController,
                              ),
                              if (widget.mileageId == null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SearchableMultiColumnDropdownField<
                                      EmployeeId
                                    >(
                                      labelText:
                                          '${AppLocalizations.of(context)!.employeeId} *',
                                      columnHeaders: [
                                        AppLocalizations.of(
                                          context,
                                        )!.employeeName,
                                        AppLocalizations.of(
                                          context,
                                        )!.employeeId,
                                      ],
                                      items: controller.employeesID,
                                      controller:
                                          controller.employeeDropDownController,
                                      selectedValue:
                                          controller.selectedEmployeeID.value,
                                      searchValue: (emp) =>
                                          '${emp.employeeName} ${emp.employeeId}',
                                      displayText: (emp) => emp.employeeId,
                                      validator: (emp) =>
                                          controller
                                              .employeeDropDownController
                                              .text
                                              .isEmpty
                                          ? AppLocalizations.of(
                                              context,
                                            )!.fieldRequired
                                          : null,
                                      onChanged: (emp) {
                                        if (emp == null) {
                                          controller.fetchEmployees();
                                        }
                                        setState(() {
                                          controller.selectedEmployeeID.value =
                                              emp;
                                          controller
                                                  .employeeDropDownController
                                                  .text =
                                              emp!.employeeId;
                                          controller.employeeName.text =
                                              emp.employeeName;
                                               controller.fetchMileageRates();
                                               controller.fetchProjectName();
                                    loadAndAppendCashAdvanceList();
                                    
                                        });
                                      },
                                      rowBuilder: (emp, searchQuery) {
                                        bool isMatch = false;
                                        if (searchQuery.isNotEmpty) {
                                          final searchableText =
                                              '${emp.employeeName} ${emp.employeeId}'
                                                  .toLowerCase();
                                          isMatch = searchableText.contains(
                                            searchQuery.toLowerCase(),
                                          );
                                        }

                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 0,
                                            horizontal: 0,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Text(
                                                    emp.employeeName,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Text(
                                                    emp.employeeId,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 8),

                                    if (employeeError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          employeeError!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

Obx(() {
                                return Column(
                                  children: controller.categoryCustomFields
                                      .where(
                                        (field) =>
                                            field['ObjectName'] ==
                                                'ExpenseCategories' &&
                                             field['IsActive'] == true,
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
                                        } // Percentage type - Make Reactive
else if (fieldType == 'Percentage') {
  if (field['_rxDoubleValue'] == null) {
    field['_rxDoubleValue'] = Rx<double?>(
      field['EnteredValue'] as double?,
    );
  }

  inputField = Obx(() {
    final rxValue = field['_rxDoubleValue'] as Rx<double?>;
    final textEditingController = TextEditingController(
      text: rxValue.value?.toString() ?? '',
    );

    textEditingController.addListener(() {
      final value = textEditingController.text;
      if (value.isEmpty) {
        if (rxValue.value != null) {
          rxValue.value = null;
          field['EnteredValue'] = null;
        }
      } else {
        final doubleValue = double.tryParse(value);
        if (doubleValue != rxValue.value) {
          rxValue.value = doubleValue;
          field['EnteredValue'] = doubleValue;
        }
      }
      field['Error'] = null;
    });

    return TextFormField(
      enabled: controller.isEnable.value,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      controller: textEditingController,
      decoration: InputDecoration(
        labelText: '$label${isMandatory ? " *" : ""}',
        border: const OutlineInputBorder(),
        errorText: field['Error'],
        suffixText: '%',
      ),
      validator: (value) {
        if (isMandatory && (value == null || value.trim().isEmpty)) {
          return '$label is required';
        }
        if (value != null && value.isNotEmpty) {
          final p = double.tryParse(value);
          if (p == null || p < 0 || p > 100) {
            return 'Enter a value between 0 and 100';
          }
        }
        return null;
      },
    );
  });
}
                                        else if (fieldType == 'Checkbox') {
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
                                        } // Percentage type - Make Reactive
else if (fieldType == 'Percentage') {
  if (field['_rxDoubleValue'] == null) {
    field['_rxDoubleValue'] = Rx<double?>(
      field['EnteredValue'] as double?,
    );
  }

  inputField = Obx(() {
    final rxValue = field['_rxDoubleValue'] as Rx<double?>;
    final textEditingController = TextEditingController(
      text: rxValue.value?.toString() ?? '',
    );

    textEditingController.addListener(() {
      final value = textEditingController.text;
      if (value.isEmpty) {
        if (rxValue.value != null) {
          rxValue.value = null;
          field['EnteredValue'] = null;
        }
      } else {
        final doubleValue = double.tryParse(value);
        if (doubleValue != rxValue.value) {
          rxValue.value = doubleValue;
          field['EnteredValue'] = doubleValue;
        }
      }
      field['Error'] = null;
    });

    return TextFormField(
      enabled: controller.isEnable.value,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      controller: textEditingController,
      decoration: InputDecoration(
        labelText: '$label${isMandatory ? " *" : ""}',
        border: const OutlineInputBorder(),
        errorText: field['Error'],
        suffixText: '%',
      ),
      validator: (value) {
        if (isMandatory && (value == null || value.trim().isEmpty)) {
          return '$label is required';
        }
        if (value != null && value.isNotEmpty) {
          final p = double.tryParse(value);
          if (p == null || p < 0 || p > 100) {
            return 'Enter a value between 0 and 100';
          }
        }
        return null;
      },
    );
  });
}
                                        else if (fieldType == 'Checkbox') {
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
                              const SizedBox(height: 4),
                              ...controller.configList
                                  .where(
                                    (field) =>
                                        field['FieldName'] == 'Project Id' &&
                                        field['IsEnabled'] == true,
                                  )
                                  .map((field) {
                                    final String label = field['FieldName'];
                                    final bool isMandatory =
                                        field['IsMandatory'] ?? false;

                                    Widget inputField;

                                    inputField = Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SearchableMultiColumnDropdownField<
                                          Project
                                        >(
                                          labelText:
                                              '${AppLocalizations.of(context)!.projectId} ${isMandatory ? "*" : ""}',
                                          columnHeaders: [
                                            AppLocalizations.of(
                                              context,
                                            )!.projectName,
                                            AppLocalizations.of(
                                              context,
                                            )!.projectId,
                                          ],
                                          enabled: controller.isEnable.value,
                                          controller:
                                              controller.projectIdController,
                                          items: controller.project,
                                          selectedValue:
                                              controller.selectedProject,
                                          searchValue: (proj) =>
                                              '${proj.name} ${proj.code}',
                                          displayText: (proj) => proj.code,
                                          onChanged: (proj) {
                                            setState(() {
                                              controller.selectedProject = proj;
                                              controller
                                                      .projectIdController
                                                      .text =
                                                  proj!.code;
                                              if (proj != null) {
                                                _showProjectError = false;
                                              }
                                            });
                                          },
                                          rowBuilder: (proj, searchQuery) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 16,
                                                  ),
                                              child: Row(
                                                children: [
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(proj.name),
                                                  ),
                                                  Expanded(
                                                    child: Text(proj.code),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                        if (_showProjectError)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.pleaseSelectProject,
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    );

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        inputField,
                                        const SizedBox(height: 18),
                                      ],
                                    );
                                  })
                                  .toList(),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (allowCashAd)
                                    MultiSelectMultiColumnDropdownField<
                                      CashAdvanceDropDownModel
                                    >(
                                      labelText: AppLocalizations.of(
                                        context,
                                      )!.cashAdvanceRequest,
                                      items: controller.cashAdvanceListDropDown,
                                      isMultiSelect: allowMultSelect ?? false,
                                      selectedValue:
                                          controller.singleSelectedItem,
                                      selectedValues:
                                          controller.multiSelectedItems,
                                      enabled: controller.isEnable.value,
                                      searchValue: (proj) =>
                                          proj.cashAdvanceReqId,
                                      displayText: (proj) =>
                                          proj.cashAdvanceReqId,
                                      validator: (proj) => proj == null
                                          ? AppLocalizations.of(
                                              context,
                                            )!.pleaseSelectCashAdvanceField
                                          : null,
                                      onChanged: (item) {
                                        controller.singleSelectedItem = item;
                                      },
                                      onMultiChanged: (items) {
                                        controller.multiSelectedItems.assignAll(
                                          items,
                                        );
                                      },
                                      columnHeaders: [
                                        AppLocalizations.of(context)!.requestId,
                                        AppLocalizations.of(
                                          context,
                                        )!.requestDate,
                                      ],
                                      rowBuilder: (proj, searchQuery) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 16,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  proj.cashAdvanceReqId,
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  proj.requestDate.toString(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                              if (allowCashAd) const SizedBox(height: 18),
                             Obx(() {
          return SearchableMultiColumnDropdownField<VehicleType>(
                                labelText:
                                    '${AppLocalizations.of(context)!.mileageType} *',
                                enabled: controller.isEnable.value,
                                columnHeaders: const ['ID'],
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
                                    controller.mileageVehicleID.text =
                                        vehicle.id;
                                    vehicleError = null;
                                    controller.selectedCurrencyMileage.value =
                                        vehicle.currency;
                                  });
                                  controller.calculateAmount();
                                },
                                controller: controller.mileageVehicleID,
                                rowBuilder: (vehicle, searchQuery) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text(vehicle.id)),
                                      ],
                                    ),
                                  );
                                },
                              );
                             }),
                            
                              if (vehicleError != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 12,
                                  ),
                                  child: Text(
                                    vehicleError!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 18),
                              buildTextField(
                                AppLocalizations.of(context)!.vehicle,
                                controller.mileageVehicleName,
                                false,
                              ),
                              const SizedBox(height: 24),
                              if (widget.mileageId != null)
                                _buildSection(
                                  title: AppLocalizations.of(
                                    context,
                                  )!.trackingHistory,
                                  children: [
                                    const SizedBox(height: 12),
                                    FutureBuilder<List<ExpenseHistory>>(
                                      future: historyFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }

                                        if (snapshot.hasError) {
                                          return Center(
                                            child: Text("No Data Available"),
                                          );
                                        }

                                        final historyList = snapshot.data!;
                                        if (historyList.isEmpty) {
                                          return Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.noHistoryMessage,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                ),
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
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gradientEnd,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.next,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
        }),
      ),
    );
  }

  DateTime? _parseDefaultDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) {
      final ms = int.tryParse(value);
      if (ms != null) return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    return null;
  }

  Widget _buildTimelineItem(ExpenseHistory item, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Column(children: [Icon(Icons.check_circle, color: Colors.blue)]),
        const SizedBox(width: 10),
        Expanded(
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.eventType,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
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
        ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.deepPurple,
              ),
            ),
            textColor: Colors.deepPurple,
            iconColor: Colors.deepPurple,
            collapsedIconColor: Colors.grey,
            childrenPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            children: children,
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller,
    bool? bool, {
    int maxLines = 1,
    Widget? suffix,
  }) {
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
          DateTime initialDate = DateTime.now();
          if (controllers.text.isNotEmpty) {
            try {
              initialDate = DateFormat(
                controller.selectedFormat?.key ?? 'dd/MM/yyyy',
              ).parseStrict(controllers.text.trim());
            } catch (e) {
              print("Invalid date in controllers.text: ${controllers.text}");
              initialDate = DateTime.now();
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
            controllers.text = DateFormat(
              controller.selectedFormat?.key ?? 'dd/MM/yyyy',
            ).format(picked);
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
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    );
  }
}
