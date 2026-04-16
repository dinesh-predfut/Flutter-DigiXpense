import 'dart:async';
import 'dart:io';
import 'package:diginexa/core/comman/widgets/loaderbutton.dart';
import 'package:diginexa/core/comman/widgets/permissionHelper.dart';
import 'package:diginexa/core/constant/Parames/colors.dart' show AppColors;
import 'package:diginexa/core/constant/Parames/params.dart' show Params;
import 'package:diginexa/data/pages/screen/widget/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, TextInputFormatter;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:diginexa/l10n/app_localizations.dart';
import 'package:diginexa/data/models.dart';
import 'package:diginexa/data/service.dart';
import 'package:diginexa/core/comman/widgets/searchDropown.dart';
import 'package:diginexa/core/comman/widgets/button.dart';
import 'package:diginexa/core/comman/widgets/pageLoaders.dart';
import 'package:diginexa/core/comman/widgets/multiselectDropdown.dart';
import 'package:intl_phone_field/intl_phone_field.dart' show IntlPhoneField;
import 'package:photo_view/photo_view.dart' show PhotoView;

class ViewEditLeavePage extends StatefulWidget {
  final bool isReadOnly;
  final bool status;
  final LeaveDetailsModel? leaveRequest;
  const ViewEditLeavePage({
    super.key,
    required this.isReadOnly,
    this.leaveRequest,
    required this.status,
  });

  @override
  State<ViewEditLeavePage> createState() => _ViewEditLeavePageState();
}

class _ViewEditLeavePageState extends State<ViewEditLeavePage> {
  final controller = Get.find<Controller>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  RxList<LeaveAnalytics> leaveAnalyticsCards = <LeaveAnalytics>[].obs;
  late Future<List<ExpenseHistory>> historyFuture;
  // late final Controller controller;
  @override
  void initState() {
    super.initState();
    // controller = Get.find();
    if (widget.leaveRequest != null) {
      historyFuture = controller.fetchLeaveHistory(widget.leaveRequest!.recId);
    }
    print("leavestart");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //  controller.uploadedImages.value.clear();
      controller.loadSequenceModules();
      _initLeaveScreen();
    });
  }

  Future<void> _initLeaveScreen() async {
    controller.updateDatesController();
    controller.isLoading.value = true;

    try {
      await Future.wait([
        controller.leaveconfiguration(),
        controller.fetchProjectName(),
        controller.fetchLocation(),
        loadLeaveAnalytics(),
        loadEmployee(),
        controller.fetchUsers(),
      ]);

      controller.markInitialized();
      controller.isLoading.value = false;
      if (widget.leaveRequest != null) {
        historyFuture = controller.fetchLeaveHistory(
          widget.leaveRequest!.recId,
        );

        if (widget.leaveRequest?.approvalStatus == "Pending" ||
            widget.leaveRequest?.stepType != "Approval") {
          controller.leaveField.value = false;
        }
        if (widget.leaveRequest?.approvalStatus == "Pending" &&
            widget.leaveRequest?.stepType == "Review") {
          controller.leaveField.value = true;
        }
        await Future.wait([
          Future(
            () => controller.loadExistingLeaveRequest(widget.leaveRequest!),
          ),
          controller.fetchExpenseDocImage(widget.leaveRequest!.recId),
        ]);
      } else {
        controller.leaveField.value = true;
      }
    } catch (e) {
      debugPrint("Init Leave Screen Error: $e");
    } finally {
      controller.isLoading.value = false;
    }
  }

  Future<void> loadLeaveAnalytics() async {
    final result = await controller.fetchLeaveAnalytics(
      Params.employeeId,
      Params.userToken,
    );

    controller.leaveCodes.assignAll(result);
  }

  Future<void> loadEmployee() async {
    final result = await controller.fetchEmployees();

    controller.employees.assignAll(result);
  }

  Future<void> _selectDateRange(BuildContext context) async {
    /// Use today as default if no start/end dates
    final today = DateTime.now();
    final initialDateRange =
        (controller.startDate.value != null && controller.endDate.value != null)
        ? DateTimeRange(
            start: controller.startDate.value!,
            end: controller.endDate.value!,
          )
        : DateTimeRange(
            start: today,
            end: today.add(const Duration(days: 1)), // default 1-day leave
          );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      initialDateRange: initialDateRange,
      initialEntryMode: DatePickerEntryMode.calendar,
    );

    if (picked != null) {
      /// Save dates
      controller.startDate.value = picked.start;
      controller.endDate.value = picked.end;

      /// Update text field
      controller.updateDatesController();

      /// Call API to create leave transactions
      await controller.createLeaveTransactions(
        employeeId: Params.employeeId,
        fromDate: picked.start.millisecondsSinceEpoch,
        toDate: picked.end.millisecondsSinceEpoch,
        leaveCode: controller.leaveCodeController.text,
      );

      /// Recalculate total leave days (Full Day by default)
      controller.calculateTotalDays();
    }
  }

  Widget _buildConfigurableField({
    required String fieldName,
    required Widget Function(bool isEnabled, bool isMandatory) builder,
  }) {
    return Obx(() {
      final config = controller.getFieldConfig(fieldName);
      if (!config.isEnabled) {
        return const SizedBox.shrink();
      }

      return builder(config.isEnabled, config.isMandatory);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   controller.leaveField.value = false;
        // });
        // if (!controller.leaveField.value) {
        //   controller.resetForm();
        //   return true;
        // }

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: controller.leaveField.value
                ? Text(AppLocalizations.of(context)!.exitForm)
                : const Text("View Leave Request"),
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
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );

        if (shouldExit ?? false) {
          controller.resetForm();
          controller.clearFormFields();
          controller.leaveField.value = false;
          controller.isLoadingviewImage.value = false;
          Navigator.of(context).pop();
          return true;
        }

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Obx(() {
            final isLeave = !controller.leaveField.value;
            return Text(
              // AppLocalizations.of(context)!.newLeaveRequest
              widget.leaveRequest != null
                  ? (isLeave
                        ? AppLocalizations.of(context)!.newLeaveRequest
                        : AppLocalizations.of(context)!.editLeaveRequest)
                  : AppLocalizations.of(context)!.newCreateLeaveRequest,
            );
          }),

          actions: [
            if (widget.isReadOnly &&
                widget.leaveRequest != null &&
                PermissionHelper.canUpdate("Leave Requisition") &&
                widget.leaveRequest?.approvalStatus != "Approved" &&
                widget.leaveRequest?.approvalStatus != "Cancelled" &&
                widget.leaveRequest?.approvalStatus != "Pending")
              Obx(
                () => IconButton(
                  icon: Icon(
                    controller.leaveField.value
                        ? Icons
                              .remove_red_eye // View
                        : Icons.edit_document, // Edit
                  ),
                  onPressed: () {
                    controller.leaveField.toggle();
                  },
                ),
              ),
          ],
        ),

        body: Obx(() {
          Color? buttonColor;
          if (widget.leaveRequest != null) {
            switch (widget.leaveRequest?.approvalStatus) {
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
          }
          if (controller.isFullPageLoading.value) {
            return Stack(children: [const SkeletonLoaderPage()]);
          }
          return controller.isLoading.value
              ? const SkeletonLoaderPage()
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with status if editing
                        if (widget.leaveRequest != null && widget.status)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  debugPrint(
                                    "Status: ${widget.leaveRequest?.approvalStatus ?? 'N/A'}",
                                  );
                                },
                                icon: const Icon(
                                  Icons.donut_large,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  widget.leaveRequest?.approvalStatus ?? 'N/A',
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
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  minimumSize: const Size(0, 32),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                        if (widget.leaveRequest == null)
                          Obx(() {
                            final hideField = controller.hasModule("Leave");

                            if (controller.isSequenceLoading.value) {
                              return const SizedBox(); // loader or empty
                            }

                            if (widget.leaveRequest == null) {
                              if (hideField) {
                                return const SizedBox.shrink(); // hide field
                              }
                            }

                            // if (widget.leaveRequest == null) {
                            //   return const SizedBox.shrink(); // hide when no request
                            // }

                            return Column(
                              children: [
                                _buildTextField(
                                  label:
                                      "${AppLocalizations.of(context)!.leaveRequisitionId} *",
                                  controller: controller.leaveIdcontroller,
                                  isReadOnly: true,
                                  validator: (value) {
                                    if (controller
                                        .leaveIdcontroller
                                        .text
                                        .isEmpty) {
                                      return '${AppLocalizations.of(context)!.leaveRequisitionId} ${AppLocalizations.of(context)!.fieldRequired}';
                                    }
                                    return null;
                                  },
                                ),
                                // const SizedBox(height: 16),
                              ],
                            );
                          }),
                        if (widget.leaveRequest != null)
                          const SizedBox(height: 16),
                        if (widget.leaveRequest != null)
                          _buildTextField(
                            label:
                                "${AppLocalizations.of(context)!.leaveRequisitionId} *",
                            controller: controller.leaveIdcontroller,
                            isReadOnly: false,
                          ),

                        if (widget.leaveRequest != null &&
                            widget.leaveRequest?.leaveCancelId?.isNotEmpty ==
                                true)
                          _buildTextField(
                            label: "Leave Cancel ID *",
                            controller: controller.leaveCancelID,
                            isReadOnly: false,
                          ),

                        if (widget.leaveRequest != null)
                          _buildTextField(
                            label:
                                "${AppLocalizations.of(context)!.appliedDate} *",
                            controller: controller.appliedDateController,
                            isReadOnly: false,
                          ),

                        if (widget.leaveRequest != null)
                          _buildTextField(
                            label:
                                "${AppLocalizations.of(context)!.employeeName} *",
                            controller: controller.employeeName,
                            isReadOnly: false,
                          ),

                        if (widget.leaveRequest != null)
                          _buildTextField(
                            label:
                                "${AppLocalizations.of(context)!.employeeId} *",
                            controller: controller.employeeIdController,
                            isReadOnly: false,
                          ),
                        // Leave Code *
                        SearchableMultiColumnDropdownField<LeaveAnalytics>(
                          enabled: controller.leaveField.value,
                          labelText:
                              '${AppLocalizations.of(context)!.leaveCode}*',
                          columnHeaders: [
                            AppLocalizations.of(context)!.code,
                            AppLocalizations.of(context)!.type,
                          ],
                          items: controller.leaveCodes,
                          selectedValue: controller.selectedLeaveCode.value,
                          searchValue: (code) =>
                              '${code.leaveCode} ${code.leaveType}',
                          displayText: (code) => code.leaveCode,
                          validator: (value) {
                            if (controller.leaveCodeController.text.isEmpty) {
                              return '${AppLocalizations.of(context)!.leaveCode} ${AppLocalizations.of(context)!.fieldRequired}';
                            }
                            return null;
                          },
                          onChanged: (code) async {
                            controller.selectedLeaveCode.value = code;
                            controller.leaveCodeController.text =
                                code?.leaveCode ?? '';
                            if (controller.leaveCodeController.text.isEmpty)
                              return;
                            await controller.createLeaveTransactions(
                              employeeId: Params.employeeId,
                              fromDate:
                                  controller
                                      .startDate
                                      .value
                                      ?.millisecondsSinceEpoch ??
                                  DateTime.now().millisecondsSinceEpoch,
                              toDate:
                                  controller
                                      .endDate
                                      .value
                                      ?.millisecondsSinceEpoch ??
                                  DateTime.now().millisecondsSinceEpoch,
                              leaveCode: controller.leaveCodeController.text,
                            );

                            controller.calculateTotalDays();
                          },
                          controller: controller.leaveCodeController,
                          rowBuilder: (code, searchQuery) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(child: Text(code.leaveCode)),
                                  Expanded(child: Text(code.leaveType)),
                                ],
                              ),
                            );
                          },
                        ),

                        // SizedBox(height: 16),
                        _buildConfigurableField(
                          fieldName: 'Delegated authority/Reliever',
                          builder: (isEnabled, isMandatory) {
                            return SizedBox(height: 16);
                          },
                        ),
                        // Reliever
                        _buildConfigurableField(
                          fieldName: 'Delegated authority/Reliever',
                          builder: (isEnabled, isMandatory) {
                            return SearchableMultiColumnDropdownField<Employee>(
                              enabled: controller.leaveField.value && isEnabled,
                              labelText:
                                  '${AppLocalizations.of(context)!.reliever}${isMandatory ? ' *' : ''}',
                              columnHeaders: [
                                AppLocalizations.of(context)!.employeeId,
                                AppLocalizations.of(context)!.name,
                                AppLocalizations.of(context)!.department,
                              ],
                              items: controller.employees,
                              selectedValue: controller.selectedReliever.value,
                              searchValue: (emp) => '${emp.id}',
                              displayText: (emp) =>
                                  '${emp.firstName ?? ''} ${emp.middleName ?? ''} ${emp.lastName ?? ''}',
                              validator: isMandatory
                                  ? (value) {
                                      if (controller
                                          .relieverController
                                          .text
                                          .isEmpty) {
                                        return '${AppLocalizations.of(context)!.reliever} ${AppLocalizations.of(context)!.fieldRequired}';
                                      }
                                      return null;
                                    }
                                  : null,
                              onChanged: (emp) {
                                controller.selectedReliever.value = emp;
                                controller.relieverController.text =
                                    emp?.id ?? '';
                              },
                              controller: controller.relieverController,
                              rowBuilder: (emp, searchQuery) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(emp.id)),
                                      Expanded(
                                        child: Text(
                                          '${emp.firstName ?? ''} ${emp.middleName ?? ''} ${emp.lastName ?? ''}',
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        // Project
                        _buildConfigurableField(
                          fieldName: AppLocalizations.of(context)!.projectId,
                          builder: (isEnabled, isMandatory) {
                            return SizedBox(height: 16);
                          },
                        ),
                        // const SizedBox(height: 16),

                        // Project
                        _buildConfigurableField(
                          fieldName: AppLocalizations.of(context)!.projectId,
                          builder: (isEnabled, isMandatory) {
                            return SearchableMultiColumnDropdownField<Project>(
                              labelText:
                                  '${AppLocalizations.of(context)!.projectId} ${isMandatory ? "*" : ""}',
                              columnHeaders: [
                                AppLocalizations.of(context)!.projectName,
                                AppLocalizations.of(context)!.projectId,
                              ],
                              items: controller.project,
                              controller: controller.projectDropDowncontroller,
                              selectedValue: controller.selectedProject,
                              validator: isMandatory
                                  ? (value) {
                                      if (controller
                                          .projectDropDowncontroller
                                          .text
                                          .isEmpty) {
                                        return '${AppLocalizations.of(context)!.projectId} ${AppLocalizations.of(context)!.fieldRequired}';
                                      }
                                      return null;
                                    }
                                  : null,
                              enabled: controller.leaveField.value,
                              searchValue: (proj) =>
                                  '${proj.name} ${proj.code}',
                              displayText: (proj) => proj.code,
                              onChanged: (proj) {
                                controller.projectDropDowncontroller.text =
                                    proj!.code;
                                setState(() {
                                  controller.selectedProject = proj;
                                  if (proj != null) {
                                    controller.showProjectError.value = false;
                                  }
                                });
                              },
                              rowBuilder: (proj, searchQuery) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10),
                                      Expanded(child: Text(proj.name)),
                                      Expanded(child: Text(proj.code)),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Dates * (Always required)
                        TextFormField(
                          controller: controller.datesController,
                          readOnly: true,
                          enabled: controller.leaveField.value,
                          decoration: InputDecoration(
                            labelText:
                                '${AppLocalizations.of(context)!.dates} *',
                            border: const OutlineInputBorder(),
                            suffixIcon: controller.leaveField.value
                                ? IconButton(
                                    icon: const Icon(Icons.calendar_today),
                                    onPressed: () => _selectDateRange(context),
                                  )
                                : null,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '${AppLocalizations.of(context)!.dates} ${AppLocalizations.of(context)!.fieldRequired}';
                            }
                            return null;
                          },
                          onTap: controller.leaveField.value
                              ? () => _selectDateRange(context)
                              : null,
                        ),

                        // Location
                        _buildConfigurableField(
                          fieldName: 'Location during leave',
                          builder: (isEnabled, isMandatory) {
                            return Column(
                              children: [
                                const SizedBox(height: 16),
                                SearchableMultiColumnDropdownField<
                                  LocationModel
                                >(
                                  labelText:
                                      '${AppLocalizations.of(context)!.location} ${isMandatory ? "*" : ""}',
                                  items: controller.location,
                                  selectedValue: controller.selectedLocation,
                                  enabled: controller.leaveField.value,
                                  controller: controller.locationController,
                                  searchValue: (proj) => proj.location,
                                  displayText: (proj) => proj.location,
                                  validator: (proj) =>
                                      isMandatory &&
                                          controller
                                              .locationController
                                              .text
                                              .isEmpty
                                      ? AppLocalizations.of(
                                          context,
                                        )!.pleaseSelectLocation
                                      : null,
                                  onChanged: (proj) {
                                    controller.selectedLocation = proj;
                                    controller.fetchPerDiemRates();
                                  },
                                  columnHeaders: [
                                    AppLocalizations.of(context)!.location,
                                    AppLocalizations.of(context)!.country,
                                  ],
                                  rowBuilder: (proj, searchQuery) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 16,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(child: Text(proj.location)),
                                          Expanded(child: Text(proj.country)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),

                        // Notifying Users
                        _buildConfigurableField(
                          fieldName: "Notifying users",
                          builder: (isEnabled, isMandatory) {
                            return MultiSelectMultiColumnDropdownField<
                              Employee
                            >(
                              enabled: controller.leaveField.value && isEnabled,
                              labelText:
                                  '${AppLocalizations.of(context)!.notifyingUsers}${isMandatory ? ' *' : ''}',
                              items: controller.employees,
                              selectedValues: controller.selectedNotifyingUsers,
                              isMultiSelect: true,
                              dropdownMaxHeight: 300,
                              searchValue: (user) =>
                                  '${user.id} ${user.firstName}',
                              displayText: (user) => user.firstName,
                              validator: isMandatory
                                  ? (value) {
                                      if (controller
                                          .selectedNotifyingUsers
                                          .isEmpty) {
                                        return '${AppLocalizations.of(context)!.notifyingUsers} ${AppLocalizations.of(context)!.fieldRequired}';
                                      }
                                      return null;
                                    }
                                  : null,
                              onMultiChanged: (users) {
                                controller.selectedNotifyingUsers.assignAll(
                                  users,
                                );
                              },
                              columnHeaders: [
                                AppLocalizations.of(context)!.employeeId,
                                AppLocalizations.of(context)!.name,
                              ],
                              rowBuilder: (emp, searchQuery) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(emp.id)),
                                      Expanded(
                                        child: Text(
                                          '${emp.firstName}${emp.middleName}${emp.lastName}',
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onChanged: (Employee? p1) {},
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Contact number
                        _buildConfigurableField(
                          fieldName: 'Contact number',
                          builder: (isEnabled, isMandatory) {
                            return Column(
                              children: [
                                SizedBox(
                                  child: IntlPhoneField(
                                    controller: controller.leavephoneController,
                                    enabled: controller.leaveField.value,
                                    keyboardType: TextInputType.phone,

                                    decoration: InputDecoration(
                                      labelText:
                                          "${AppLocalizations.of(context)!.contactNumber} ${isMandatory ? "*" : ""}",
                                      labelStyle: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      counterText: "",
                                    ),
                                    initialCountryCode: 'IN',
                                    onChanged: (phone) {
                                      controller.leavephoneController.text =
                                          phone.number;
                                      controller.countryCodeController.text =
                                          phone.countryCode;
                                    },
                                    onCountryChanged: (country) {
                                      controller.countryCodeController.text =
                                          "+${country.dialCode}";
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: isMandatory
                                        ? (value) {
                                            if (controller
                                                .leavephoneController
                                                .text
                                                .isEmpty) {
                                              return '${AppLocalizations.of(context)!.contactNumber} ${AppLocalizations.of(context)!.fieldRequired}';
                                            }
                                            return null;
                                          }
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),

                        // const SizedBox(height: 8),

                        // Comments *
                        TextFormField(
                          controller: controller.commentsController,
                          enabled: controller.leaveField.value,
                          maxLines: 3,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            labelText:
                                '${AppLocalizations.of(context)!.reason} *',
                            border: const OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '${AppLocalizations.of(context)!.comments} ${AppLocalizations.of(context)!.fieldRequired}';
                            }
                            return null;
                          },
                          onChanged: controller.leaveField.value
                              ? (value) {
                                  controller.comments.value = value;
                                }
                              : null,
                        ),

                  
                        _buildConfigurableField(
                          fieldName: 'Availability during leave',
                          builder: (isEnabled, isMandatory) {
                            return SizedBox(height: 16);
                          },
                        ),
                        // Availability During Leave
                        _buildConfigurableField(
                          fieldName: 'Availability during leave',
                          builder: (isEnabled, isMandatory) {
                            return SearchableMultiColumnDropdownField<String>(
                              enabled: controller.leaveField.value && isEnabled,
                              labelText:
                                  '${AppLocalizations.of(context)!.availabilityDuringLeave}${isMandatory ? ' *' : ''}',
                              columnHeaders: [
                                AppLocalizations.of(context)!.availability,
                              ],
                              items: [
                                AppLocalizations.of(
                                  context,
                                )!.availabilityDuringLeave,
                                AppLocalizations.of(
                                  context,
                                )!.availableForUrgentMatters,
                              ],
                              selectedValue:
                                  controller.selectedAvailability.value,
                              searchValue: (option) => option,
                              displayText: (option) => option,
                              validator: isMandatory
                                  ? (value) {
                                      if (value == null ||
                                          controller
                                              .availabilityController
                                              .text
                                              .isEmpty) {
                                        return '${AppLocalizations.of(context)!.availabilityDuringLeave} ${AppLocalizations.of(context)!.fieldRequired}';
                                      }
                                      return null;
                                    }
                                  : null,
                              onChanged: (option) {
                                controller.selectedAvailability.value =
                                    option ?? '';
                                controller.availabilityController.text =
                                    option ?? '';
                              },
                              controller: controller.availabilityController,
                              rowBuilder: (option, searchQuery) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [Expanded(child: Text(option))],
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        // const SizedBox(height: 16),
                        _buildConfigurableField(
                          fieldName: 'Out  of Office Message',
                          builder: (isEnabled, isMandatory) {
                            return SizedBox(height: 16);
                          },
                        ),
                        // Out of Office Message
                        _buildConfigurableField(
                          fieldName: 'Out  of Office Message',
                          builder: (isEnabled, isMandatory) {
                            return TextFormField(
                              controller:
                                  controller.outOfOfficeMessageController,
                              enabled: controller.leaveField.value && isEnabled,
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText:
                                    '${AppLocalizations.of(context)!.outOfOfficeMessage}${isMandatory ? ' *' : ''}',
                                border: const OutlineInputBorder(),
                                alignLabelWithHint: true,
                              ),
                              validator: isMandatory
                                  ? (value) {
                                      if (value == null || value.isEmpty) {
                                        return '${AppLocalizations.of(context)!.outOfOfficeMessage} ${AppLocalizations.of(context)!.fieldRequired}';
                                      }
                                      return null;
                                    }
                                  : null,
                              onChanged:
                                  controller.leaveField.value && isEnabled
                                  ? (value) =>
                                        controller.outOfOfficeMessage.value =
                                            value
                                  : null,
                            );
                          },
                        ),

                        // const SizedBox(height: 16),
                        _buildConfigurableField(
                          fieldName: 'Notify HR',
                          builder: (isEnabled, isMandatory) {
                            return SizedBox(height: 16);
                          },
                        ),
                        // Notify HR Checkbox
                        _buildConfigurableField(
                          fieldName: 'Notify HR',
                          builder: (isEnabled, isMandatory) {
                            if (!isEnabled) return const SizedBox.shrink();

                            return CheckboxListTile(
                              title: Text(
                                AppLocalizations.of(context)!.notifyHR,
                              ),
                              value: controller.notifyHR.value,
                              onChanged:
                                  controller.leaveField.value && isEnabled
                                  ? (value) => controller.notifyHR.value =
                                        value ?? false
                                  : null,
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            );
                          },
                        ),

                        // Notify Team Members Checkbox
                        _buildConfigurableField(
                          fieldName: 'Notify team members',
                          builder: (isEnabled, isMandatory) {
                            if (!isEnabled) return const SizedBox.shrink();

                            return CheckboxListTile(
                              title: Text(
                                AppLocalizations.of(context)!.notifyTeamMembers,
                              ),
                              value: controller.notifyTeam.value,
                              onChanged:
                                  controller.leaveField.value && isEnabled
                                  ? (value) => controller.notifyTeam.value =
                                        value ?? false
                                  : null,
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            );
                          },
                        ),

                        // const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.uploadAttachments,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Obx(() {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Upload Box
                              InkWell(
                                onTap: !controller.leaveField.value
                                    ? null
                                    : controller.pickImages,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                      style: BorderStyle.solid,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.cloud_upload, size: 40),
                                      const SizedBox(height: 8),
                                      Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.uploadFileOrDragDrop,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              if (controller.uploadedImages.isNotEmpty)
                                SizedBox(
                                  height: 90,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: controller.uploadedImages.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 8),
                                    itemBuilder: (context, index) {
                                      final file =
                                          controller.uploadedImages[index];

                                      return Stack(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              _openImagePreview(context, file);
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.file(
                                                file,
                                                width: 90,
                                                height: 90,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),

                                          if (controller.leaveField.value)
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap: () {
                                                  controller.uploadedImages
                                                      .removeAt(index);
                                                },
                                                child: Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.black54,
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ),

                              _buildConfigurableField(
                                fieldName: 'Paid/Unpaid Leave flag',
                                builder: (isEnabled, isMandatory) {
                                  if (!isEnabled)
                                    return const SizedBox.shrink();

                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          debugPrint(
                                            "Status: ${widget.leaveRequest?.approvalStatus ?? 'N/A'}",
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.density_small_outlined,
                                          size: 8,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          "Paid",
                                          style: TextStyle(
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
                                  );
                                },
                              ),
                            ],
                          );
                        }),

                        const SizedBox(height: 12),

                        Obx(() {
                          if (controller.leaveDays.isEmpty) {
                            return const SizedBox();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: controller.leaveDays.map((leaveDay) {
                              final date = DateTime.fromMillisecondsSinceEpoch(
                                leaveDay.transDate,
                                isUtc: true,
                              ).toLocal();

                              return Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    /// Date column
                                    Expanded(
                                      child: Text(
                                        DateFormat('dd-MM-yyyy').format(date),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    /// Day type column (ALWAYS Expanded)
                                    Expanded(
                                      child: leaveDay.noOfDays == 0
                                          ? const Text(
                                              "Non Working Day",
                                              style: TextStyle(fontSize: 12),
                                            )
                                          : SearchableMultiColumnDropdownField<
                                              String
                                            >(
                                              enabled:
                                                  controller.leaveField.value &&
                                                  !leaveDay.isHoliday,
                                              labelText: AppLocalizations.of(
                                                context,
                                              )!.dayType,
                                              items: [
                                                'Full Day',
                                                'First Half',
                                                'Second Half',
                                              ],
                                              selectedValue:
                                                  leaveDay.dayType.value,
                                              searchValue: (option) => option,
                                              displayText: (option) => option,
                                              onChanged: (option) {
                                                leaveDay.dayType.value =
                                                    option!;
                                                controller.calculateTotalDays();
                                              },
                                              rowBuilder: (option, searchQuery) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 16,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(option),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              columnHeaders: const ['Day Type'],
                                            ),
                                    ),

                                    // const SizedBox(width: 12),

                                    // /// New Status button column
                                    // if (leaveDay.approvalStatus != null &&
                                    //     widget.leaveRequest!.approvalStatus !=
                                    //         "Created")
                                    //   Expanded(
                                    //     child: OutlinedButton(
                                    //       onPressed: () {
                                    //         // Optionally handle button click
                                    //       },
                                    //       style: OutlinedButton.styleFrom(
                                    //         side: const BorderSide(
                                    //           color: Colors.blue,
                                    //         ),
                                    //         shape: RoundedRectangleBorder(
                                    //           borderRadius:
                                    //               BorderRadius.circular(8),
                                    //         ),
                                    //         padding: const EdgeInsets.symmetric(
                                    //           vertical: 12,
                                    //         ),
                                    //       ),
                                    //       child: Text(
                                    //         leaveDay.approvalStatus ??
                                    //             'Pending',
                                    //         style: const TextStyle(
                                    //           fontSize: 12,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        }),

                        const SizedBox(height: 12),

                        Obx(
                          () => Text(
                            '${AppLocalizations.of(context)!.total} ${controller.totalRequestedDays.value} ${AppLocalizations.of(context)!.days} ${AppLocalizations.of(context)!.ofLeave}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        if (widget.leaveRequest != null)
                          const SizedBox(height: 10),
                        if (widget.leaveRequest != null)
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
                                      // print("Trackingitem: $item");
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
                        const SizedBox(height: 32),

                        // Action Buttons
                        if (widget.leaveRequest != null &&
                            !widget.isReadOnly &&
                            widget.leaveRequest?.stepType?.isNotEmpty == true &&
                            PermissionHelper.canUpdate("Leave Requisition"))
                          _buildApprovalActionButtons(),
                        if ((controller.leaveField.value ||
                                widget.isReadOnly) &&
                            PermissionHelper.canUpdate("Leave Requisition"))
                          _buildActionButtons(),
                        if (widget.leaveRequest != null &&
                            !widget.status &&
                            (widget
                                    .leaveRequest!
                                    .cancellationApprovalStatus
                                    ?.isEmpty ??
                                true) &&
                            PermissionHelper.canUpdate("Leave Requisition"))
                          _buildViewModeButtons(),

                        if (widget.isReadOnly &&
                            PermissionHelper.canUpdate("Leave Requisition") &&
                            widget.leaveRequest != null &&
                            (widget.leaveRequest?.requestType ==
                                    "LeaveCancellation" ||
                                widget.leaveRequest?.leaveStatus ==
                                        "Approved" &&
                                    widget
                                            .leaveRequest!
                                            .cancellationApprovalStatus ==
                                        "Pending"))
                          _buildViewModeButtonsCancelation(),

                        if (widget.isReadOnly &&
                            PermissionHelper.canUpdate("Leave Requisition") &&
                            widget.leaveRequest != null &&
                            widget.leaveRequest?.approvalStatus != "Approved" &&
                            widget.leaveRequest?.approvalStatus !=
                                "Cancelled" &&
                            widget.leaveRequest?.approvalStatus != "Pending")
                          _buildViewModeButtons(),
                        if (!PermissionHelper.canUpdate("Leave Requisition"))
                          _buildViewModeButtons(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                );
        }),
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
                  Text(
                    item.eventType,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(item.notes),
                  const SizedBox(height: 6),
                  Text(
                    '${AppLocalizations.of(context)!.submittedOn} ${DateFormat('dd-MM-yyyy').format(item.createdDate)}',
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

  void _openPartialCancelPopup(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// TITLE
                  Text(
                    AppLocalizations.of(context)!.leavePartialCancellation,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// REASON
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText:
                          "${AppLocalizations.of(context)!.reasonForCancellation} *",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// LEAVE DAYS
                  if (controller.leaveDays.isNotEmpty)
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: controller.leaveDays.map((leaveDay) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  /// DATE
                                  Expanded(
                                    child: Text(
                                      DateFormat('dd-MM-yyyy').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                          leaveDay.transDate,
                                          isUtc: true,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: leaveDay.isHoliday == true
                                        ? const Text(
                                            "Non Working Day",
                                            style: TextStyle(fontSize: 12),
                                          )
                                        : SearchableMultiColumnDropdownField<
                                            String
                                          >(
                                            labelText: AppLocalizations.of(
                                              context,
                                            )!.dayType,
                                            items: [
                                              'Full Day',
                                              'First Half',
                                              'Second Half',
                                            ],
                                            selectedValue:
                                                leaveDay.dayType.value,
                                            searchValue: (option) => option,
                                            displayText: (option) => option,
                                            onChanged: (option) {
                                              leaveDay.dayType.value = option!;
                                              controller.calculateTotalDays();

                                              /// track modified only
                                              if (option !=
                                                  leaveDay.originalDayType) {
                                                controller.modifiedDays[leaveDay
                                                        .recId!] =
                                                    option!;
                                              } else {
                                                controller.modifiedDays.remove(
                                                  leaveDay.recId,
                                                );
                                              }
                                            },
                                            rowBuilder: (option, searchQuery) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 16,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(option),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            columnHeaders: const ['Day Type'],
                                          ),
                                  ),

                                  /// DAY TYPE
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  /// ACTIONS
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            controller.resetForm();
                            Navigator.pop(context);
                          },
                          child: Text(AppLocalizations.of(context)!.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final reason = reasonController.text.trim();

                            if (reason.isEmpty) {
                              Fluttertoast.showToast(
                                msg: "Enter cancellation reason",
                              );
                              return;
                            }

                            await controller.submitPartialCancellation(
                              context,
                              leaveReqId: widget.leaveRequest!.recId,
                              reason: reason,
                            );
                          },
                          child: Text(AppLocalizations.of(context)!.save),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  void _openImagePreview(BuildContext context, File image) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              PhotoView(
                imageProvider: FileImage(image),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildApprovalActionButtons() {
    // Add null checks
    if (widget.leaveRequest == null) return const SizedBox.shrink();

    final stepType = widget.leaveRequest!.stepType;

    if (stepType == null || stepType.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        if (stepType == "Review" &&
            widget.leaveRequest!.requestType != "LeaveCancellation")
          Row(
            children: [
              /// ================= UPDATE =================
              Expanded(
                child: Obx(() {
                  final isLoading = controller.buttonLoaders['update'] ?? false;
                  final isAnyLoading = controller.buttonLoaders.values.any(
                    (loading) => loading == true,
                  );
                  return ElevatedButton(
                    onPressed: isLoading || isAnyLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              controller.setButtonLoading('update', true);
                              try {
                                await controller.submitApprovalLeaveRequest(
                                  context,
                                  false,
                                  widget.leaveRequest!.workitemrecid!,
                                );
                              } finally {
                                controller.setButtonLoading('update', false);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 3, 20, 117),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.update,
                            style: const TextStyle(color: Colors.white),
                          ),
                  );
                }),
              ),

              const SizedBox(width: 12),

              /// ================= UPDATE & ACCEPT =================
              Expanded(
                child: Obx(() {
                  final isLoading =
                      controller.buttonLoaders['update_accept'] ?? false;
                  final isAnyLoading = controller.buttonLoaders.values.any(
                    (loading) => loading == true,
                  );
                  return ElevatedButton(
                    onPressed: isLoading || isAnyLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              controller.setButtonLoading(
                                'update_accept',
                                true,
                              );
                              try {
                                await controller.submitApprovalLeaveRequest(
                                  context,
                                  true,
                                  widget.leaveRequest!.workitemrecid!,
                                );
                              } finally {
                                controller.setButtonLoading(
                                  'update_accept',
                                  false,
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 3, 20, 117),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.updateAndAccept,
                            style: const TextStyle(color: Colors.white),
                          ),
                  );
                }),
              ),
            ],
          ),

        if (stepType == "Review" &&
            widget.leaveRequest!.requestType != "LeaveCancellation")
          const SizedBox(height: 12),

        if (stepType == "Review" &&
            widget.leaveRequest!.requestType != "LeaveCancellation")
          Row(
            children: [
              /// ================= REJECT =================
              Expanded(
                child: Obx(() {
                  final isLoading = controller.buttonLoaders['reject'] ?? false;
                  final isAnyLoading = controller.buttonLoaders.values.any(
                    (loading) => loading == true,
                  );
                  return ElevatedButton(
                    onPressed: isLoading || isAnyLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              controller.setButtonLoading('reject', true);
                              try {
                                showActionPopup(context, "Reject");
                              } finally {
                                controller.setButtonLoading('reject', false);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 238, 20, 20),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.reject,
                            style: const TextStyle(color: Colors.white),
                          ),
                  );
                }),
              ),

              const SizedBox(width: 12),

              /// ================= CLOSE =================
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    controller.closeField();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: Text(AppLocalizations.of(context)!.close),
                ),
              ),
            ],
          ),

        if (stepType == "Approval" ||
            widget.leaveRequest!.requestType == "LeaveCancellation")
          Row(
            children: [
              Obx(() {
                final isLoading = controller.buttonLoaders['approve'] ?? false;
                return Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            controller.setButtonLoading('approve', true);
                            showActionPopup(context, "Approve");
                            controller.setButtonLoading('approve', false);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 30, 117, 3),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.approvals,
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                );
              }),

              const SizedBox(width: 12),

              Obx(() {
                final isLoading =
                    controller.buttonLoaders['reject_approval'] ?? false;
                return Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            controller.setButtonLoading(
                              'reject_approval',
                              true,
                            );
                            showActionPopup(context, "Reject");
                            controller.setButtonLoading(
                              'reject_approval',
                              false,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 238, 20, 20),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.reject,
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                );
              }),
            ],
          ),

        if (stepType == "Approval" ||
            widget.leaveRequest!.requestType == "LeaveCancellation")
          Row(
            children: [
              Obx(() {
                final isLoading = controller.buttonLoaders['escalate'] ?? false;
                return Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            controller.setButtonLoading('escalate', true);
                            showActionPopup(context, "Escalate");
                            controller.setButtonLoading('escalate', false);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 3, 20, 117),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.escalate,
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                );
              }),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    controller.closeField();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: Text(AppLocalizations.of(context)!.close),
                ),
              ),
            ],
          ),
      ],
    );
  }

  void showActionPopup(BuildContext context, String status) {
    final TextEditingController commentController = TextEditingController();

    bool isCommentError = false;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Drag Handle
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

                    /// Title
                    Text(
                      AppLocalizations.of(context)!.action,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// Escalate User Dropdown
                    if (status == "Escalate") ...[
                      Text(
                        '${AppLocalizations.of(context)!.selectUser} *',
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 8),

                      Obx(
                        () => SearchableMultiColumnDropdownField<User>(
                          labelText: '${AppLocalizations.of(context)!.user} *',
                          columnHeaders: [
                            AppLocalizations.of(context)!.userName,
                            AppLocalizations.of(context)!.userId,
                          ],
                          items: controller.userList,
                          selectedValue: controller.selectedUser.value,
                          searchValue: (user) =>
                              '${user.userName} ${user.userId}',
                          displayText: (user) => user.userId,
                          controller: controller.userIdController,
                          onChanged: (user) {
                            controller.userIdController.text =
                                user?.userId ?? '';
                            controller.selectedUser.value = user;
                          },
                          rowBuilder: (user, searchQuery) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(child: Text(user.userName)),
                                  Expanded(child: Text(user.userId)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],

                    /// Comment Label
                    Text(
                      '${AppLocalizations.of(context)!.comments} ${status == "Reject" ? "*" : ""}',
                      style: const TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 8),

                    /// Comment Field
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(
                          context,
                        )!.enterCommentHere,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorText: isCommentError
                            ? 'Comment is required.'
                            : null,
                      ),
                      onChanged: (value) {
                        if (isCommentError && value.trim().isNotEmpty) {
                          setState(() => isCommentError = false);
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    /// Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        /// Close Button
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  controller.closeField();
                                  Navigator.pop(context);
                                },
                          child: Text(AppLocalizations.of(context)!.close),
                        ),

                        const SizedBox(width: 8),

                        /// Action Button
                        ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final comment = commentController.text.trim();

                                  if (status != "Approve" && comment.isEmpty) {
                                    setState(() => isCommentError = true);
                                    return;
                                  }

                                  setState(() => isLoading = true);

                                  final success = await controller
                                      .postApprovalActionLeavel(
                                        context,
                                        workitemrecid: [
                                          controller.workitemrecid!,
                                        ],
                                        decision: status,
                                        comment: comment,
                                      );

                                  if (!context.mounted) return;

                                  setState(() => isLoading = false);

                                  if (success) {
                                    controller.isApprovalEnable.value = false;

                                    Navigator.pop(context);

                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.leavePendingApprovals,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),

                          /// Button Loader
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(status),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (widget.leaveRequest != null) ...[
          // REJECTED - RESUBMIT BUTTON
          if (controller.leaveField.value &&
              widget.leaveRequest?.approvalStatus == "Rejected" &&
              widget.isReadOnly)
            Obx(() {
              final isResubmitLoading = controller.isButtonLoading('resubmit');
              final isAnyLoading = controller.isAnyButtonLoading();

              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: const Color.fromARGB(255, 29, 1, 128),
                  ),
                  onPressed: (isResubmitLoading || isAnyLoading)
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            controller.setButtonLoading('resubmit', true);
                            try {
                              controller.calculateTotalDays();
                              await controller.submitLeaveRequest(
                                context,
                                true,
                                true,
                              );
                              controller.uploadedImages.clear();
                              controller.fileItems.clear();
                            } finally {
                              controller.setButtonLoading('resubmit', false);
                            }
                          }
                        },
                  child: isResubmitLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.resubmit,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              );
            }),

          if (controller.leaveField.value) const SizedBox(height: 20),

          // REJECTED - UPDATE & CANCEL BUTTONS
          if (controller.leaveField.value &&
              widget.leaveRequest?.approvalStatus == "Rejected" &&
              widget.isReadOnly)
            Row(
              children: [
                Obx(() {
                  final isUpdateLoading = controller.isButtonLoading('update');
                  final isAnyLoading = controller.isAnyButtonLoading();

                  return Expanded(
                    child: ElevatedButton(
                      onPressed: (isUpdateLoading || isAnyLoading)
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                controller.setButtonLoading('update', true);
                                try {
                                  controller.calculateTotalDays();
                                  await controller.submitLeaveRequest(
                                    context,
                                    false,
                                    false,
                                  );
                                  controller.uploadedImages.clear();
                                  controller.fileItems.clear();
                                } finally {
                                  controller.setButtonLoading('update', false);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E7503),
                      ),
                      child: isUpdateLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context)!.update,
                              style: const TextStyle(color: Colors.white),
                            ),
                    ),
                  );
                }),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.chancelButtonLeave(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: Text(AppLocalizations.of(context)!.close),
                  ),
                ),
              ],
            ),

          // CREATED - SUBMIT/SAVE/CANCEL BUTTONS
          if (controller.leaveField.value &&
              widget.leaveRequest?.approvalStatus == "Created" &&
              widget.isReadOnly)
            Column(
              children: [
                /// SUBMIT BUTTON
                Obx(() {
                  final isSubmitLoading = controller.isButtonLoading('submit');
                  final isAnyLoading = controller.isAnyButtonLoading();

                  return CustomLoaderButton(
                    text: AppLocalizations.of(context)!.submit,
                    isLoading: isSubmitLoading,
                    disabled: isAnyLoading,
                    width: double.infinity,
                    height: 52,
                    borderRadius: BorderRadius.circular(30),
                    backgroundColor: const Color.fromARGB(255, 29, 1, 128),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      controller.setButtonLoading('submit', true);

                      try {
                        controller.calculateTotalDays();
                        await controller.submitLeaveRequest(
                          context,
                          true,
                          false,
                        );
                        controller.uploadedImages.clear();
                        controller.fileItems.clear();
                      } finally {
                        controller.setButtonLoading('submit', false);
                      }
                    },
                  );
                }),

                const SizedBox(height: 12),

                /// SAVE & CANCEL BUTTONS
                Row(
                  children: [
                    /// SAVE BUTTON
                    Obx(() {
                      final isSaveLoading = controller.isButtonLoading('save');
                      final isAnyLoading = controller.isAnyButtonLoading();

                      return Expanded(
                        child: CustomLoaderButton(
                          text: AppLocalizations.of(context)!.save,
                          isLoading: isSaveLoading,
                          disabled: isAnyLoading,
                          backgroundColor: const Color(0xFF1E7503),
                          height: 52,
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;

                            controller.setButtonLoading('save', true);

                            try {
                              controller.calculateTotalDays();
                              await controller.submitLeaveRequest(
                                context,
                                false,
                                false,
                              );
                              controller.uploadedImages.clear();
                              controller.fileItems.clear();
                            } finally {
                              controller.setButtonLoading('save', false);
                            }
                          },
                        ),
                      );
                    }),

                    const SizedBox(width: 12),

                    /// CANCEL BUTTON
                    Expanded(
                      child: CustomLoaderButton(
                        text: AppLocalizations.of(context)!.close,
                        isLoading: false,
                        disabled: false,
                        backgroundColor: Colors.grey,
                        height: 52,
                        onPressed: () {
                          controller.clearTimeSheetForm();
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

          // APPROVED - FULL/PARTIAL CANCEL BUTTONS
          if (widget.isReadOnly &&
              PermissionHelper.canUpdate("Leave Requisition") &&
              widget.leaveRequest!.approvalStatus == "Approved" &&
              (widget.leaveRequest!.leaveStatus == "Approved" ||
                  widget.leaveRequest!.leaveStatus != "PartiallyCancelled" &&
                      widget.leaveRequest!.leaveStatus != "Cancelled" ||
                  widget.leaveRequest!.leaveStatus == "Created") &&
              widget.leaveRequest?.leaveCancelId == null)
            Row(
              children: [
                Obx(() {
                  final isLoading = controller.isButtonLoading('cancel');
                  return Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              _showFullCancelDialog(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE99797),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.red,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context)!.fullyCancel,
                              style: TextStyle(color: Colors.red),
                            ),
                    ),
                  );
                }),
                const SizedBox(width: 12),
                Obx(() {
                  final isLoading = controller.isButtonLoading('cancel');
                  return Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              controller.setButtonLoading('cancel', true);
                              try {
                                _openPartialCancelPopup(context);
                              } finally {
                                controller.setButtonLoading('cancel', false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE99797),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.red,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context)!.partialCancel,
                              style: TextStyle(color: Colors.red),
                            ),
                    ),
                  );
                }),
              ],
            ),

          // APPROVED WITH CANCEL ID
          // if (widget.isReadOnly &&
          //     widget.leaveRequest!.approvalStatus == "Approved" &&
          //     widget.leaveRequest?.requestType != "LeaveCancellation" &&
          //     widget.leaveRequest?.leaveCancelId?.isNotEmpty == true)
          //   Row(
          //     children: [
          //       const SizedBox(width: 12),
          //       Expanded(
          //         child: ElevatedButton(
          //           onPressed: () {
          //             Navigator.of(context).pop();
          //           },
          //           style: ElevatedButton.styleFrom(
          //             backgroundColor: Colors.grey,
          //           ),
          //           child: const Text("Closes"),
          //         ),
          //       ),
          //     ],
          //   ),

          // APPROVED WITHOUT CANCEL ID - CLOSE BUTTON
          if (widget.isReadOnly &&
              (widget.leaveRequest!.approvalStatus == "Cancelled" ||
                  widget.leaveRequest!.approvalStatus == "Approved") &&
              (widget.leaveRequest!.leaveStatus == "Approved" ||
                  widget.leaveRequest!.leaveStatus != "PartiallyCancelled" ||
                  widget.leaveRequest!.leaveStatus == "Created" ||
                  widget.leaveRequest!.leaveStatus == "Cancelled" ||
                  widget.leaveRequest!.approvalStatus == "Cancelled") &&
              widget.leaveRequest?.leaveCancelId == null)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),

          // PENDING - CANCEL/CLOSE BUTTONS
          if (widget.isReadOnly &&
              widget.status &&
              widget.leaveRequest?.approvalStatus == "Pending")
            Row(
              children: [
                Obx(() {
                  final isLoading = controller.isButtonLoading('cancel');
                  return Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              controller.setButtonLoading('cancel', true);
                              try {
                                await controller.leavecancelExpense(
                                  context,
                                  widget.leaveRequest!.recId.toString(),
                                );
                              } finally {
                                controller.setButtonLoading('cancel', false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE99797),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.red,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.red),
                            ),
                    ),
                  );
                }),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),
          if (widget.leaveRequest!.leaveStatus == "PartiallyCancelled")
            _buildViewModeButtons(),
          const SizedBox(height: 28),
        ] else ...[
          // NEW LEAVE REQUEST - SUBMIT BUTTON
          Center(
            child: Column(
              children: [
                /// 🚀 Submit Button
                Obx(() {
                  final isSubmitLoading = controller.isButtonLoading('submit');
                  final isAnyLoading = controller.isAnyButtonLoading();

                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: (isSubmitLoading || isAnyLoading)
                          ? null
                          : () async {
                              // _isSubmitAttempted = true;

                              /// Form validation
                              if (!_formKey.currentState!.validate()) {
                                setState(() {});
                                return;
                              }

                              /// Requested days validation
                              if (controller.totalRequestedDays.value == 0) {
                                Fluttertoast.showToast(
                                  msg: "Requested days cannot be zero",
                                  backgroundColor: Colors.red[100],
                                  textColor: Colors.red[800],
                                );
                                return;
                              }

                              controller.setButtonLoading('submit', true);

                              try {
                                controller.calculateTotalDays();
                                await controller.submitLeaveRequest(
                                  context,
                                  true,
                                  false,
                                );

                                controller.uploadedImages.clear();
                                controller.fileItems.clear();
                              } finally {
                                controller.setButtonLoading('submit', false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        backgroundColor: AppColors.gradientEnd,
                      ),
                      child: isSubmitLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context)!.submit,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                /// 💾 Save & Cancel Buttons
                Row(
                  children: [
                    /// Save Button
                    Expanded(
                      child: Obx(() {
                        final isSaveLoading = controller.isButtonLoading(
                          'saveDraft',
                        );
                        final isAnyLoading = controller.isAnyButtonLoading();

                        return ElevatedButton(
                          onPressed: (isSaveLoading || isAnyLoading)
                              ? null
                              : () async {
                                  // _isSubmitAttempted = true;

                                  if (!_formKey.currentState!.validate()) {
                                    setState(() {});
                                    return;
                                  }

                                  controller.setButtonLoading(
                                    'saveDraft',
                                    true,
                                  );

                                  try {
                                    controller.calculateTotalDays();
                                    await controller.submitLeaveRequest(
                                      context,
                                      false,
                                      false,
                                    );

                                    controller.uploadedImages.clear();
                                    controller.fileItems.clear();
                                  } finally {
                                    controller.setButtonLoading(
                                      'saveDraft',
                                      false,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(130, 50),
                            backgroundColor: const Color.fromARGB(
                              241,
                              20,
                              94,
                              2,
                            ),
                          ),
                          child: isSaveLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  AppLocalizations.of(context)!.save,
                                  style: const TextStyle(color: Colors.white),
                                ),
                        );
                      }),
                    ),

                    const SizedBox(width: 10),

                    /// Cancel Button
                    Expanded(
                      child: Obx(() {
                        final isCancelLoading = controller.isButtonLoading(
                          'cancel',
                        );
                        final isAnyLoading = controller.isAnyButtonLoading();

                        return ElevatedButton(
                          onPressed: (isCancelLoading || isAnyLoading)
                              ? null
                              : () async {
                                  controller.setButtonLoading('cancel', true);

                                  try {
                                    controller.resetForm();
                                    Navigator.pop(context);
                                  } finally {
                                    controller.setButtonLoading(
                                      'cancel',
                                      false,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(130, 50),
                            backgroundColor: Colors.grey,
                          ),
                          child: isCancelLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  AppLocalizations.of(context)!.close,
                                  style: const TextStyle(color: Colors.white),
                                ),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showFullCancelDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            AppLocalizations.of(context)!.leaveFullCancellation,
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reasonController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText:
                      "${AppLocalizations.of(context)!.reasonForCancellation} *",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = reasonController.text.trim();

                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter cancellation reason"),
                    ),
                  );
                  return;
                }

                controller.setButtonLoading('cancel', true);
                controller
                    .cancelLeave(
                      context,
                      leaveReqId: widget.leaveRequest!.recId,
                      cancellationType: "Full",
                      reason: reason,
                    )
                    .whenComplete(() {
                      controller.setButtonLoading('cancel', false);
                    });

                // controller
                //     .cancelExpense(
                //       context,
                //       widget.leaveRequest!.recId.toString(),
                //       reason, // 👈 pass reason
                //     )
                //     .whenComplete(() {
                //   controller.setButtonLoading('cancel', false);
                // });
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
  }

  Widget _buildViewModeButtons() {
    return Column(
      children: [
        const SizedBox(height: 22),
        if (!controller.leaveField.value)
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.grey,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              AppLocalizations.of(context)!.close,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildViewModeButtonsCancelation() {
    return Row(
      children: [
        if (widget.leaveRequest!.cancellationApprovalStatus == "Pending")
          Obx(() {
            final isLoading = controller.buttonLoaders['cancel'] ?? false;
            return Expanded(
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        controller.setButtonLoading('cancel', true);
                        controller
                            .submitExpenseCancel(
                              contextRecId:
                                  widget.leaveRequest!.cancellationRECID!,
                              context: context,
                            )
                            .whenComplete(() {
                              controller.setButtonLoading('cancel', false);
                            });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE99797),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.red,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("Cancel", style: TextStyle(color: Colors.red)),
              ),
            );
          }),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: const Text("Close"),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'draft':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool isReadOnly,
    void Function(String)? onChanged,
    List<TextInputFormatter>? inputFormatters,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          enabled: isReadOnly,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 16,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

// Add to your main.dart or wherever you initialize GetX
void initializecontroller() {
  Get.put(Controller());
}
