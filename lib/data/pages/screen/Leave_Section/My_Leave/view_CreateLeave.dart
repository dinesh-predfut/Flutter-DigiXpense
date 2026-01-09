import 'dart:async';
import 'dart:io';
import 'package:digi_xpense/core/constant/Parames/params.dart' show Params;
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, TextInputFormatter;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:digi_xpense/l10n/app_localizations.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';
import 'package:digi_xpense/core/comman/widgets/button.dart';
import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/core/comman/widgets/multiselectDropdown.dart';
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
  final Controller controller = Get.find<Controller>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  RxList<LeaveAnalytics> leaveAnalyticsCards = <LeaveAnalytics>[].obs;

  @override
  void initState() {
    super.initState();
    // print("leavestart${widget.leaveRequest?.leaveCancelId.isEmpty}");
    print("leavestart${widget.leaveRequest?.approvalStatus}");

    _initLeaveScreen();
  }

  Future<void> _initLeaveScreen() async {
    controller.updateDatesController();
    controller.isLoading.value = true;

    try {
      /// 🔥 HEAVY APIs → RUN IN PARALLEL
      await Future.wait([
        controller.leaveconfiguration(),
        controller.fetchProjectName(),
        controller.fetchLocation(),
      ]);

      /// 🔁 LIGHT APIs → RUN IN PARALLEL
      await Future.wait([
        loadLeaveAnalytics(),
        loadEmployee(),
        controller.fetchUsers(),
      ]);

      controller.markInitialized();

      /// 📄 EXISTING LEAVE REQUEST
      if (widget.leaveRequest != null) {
        await Future.wait([
        
          Future(
            () => controller.loadExistingLeaveRequest(widget.leaveRequest!),
          ),
            // controller.fetchExpenseDocImage(widget.leaveRequest!.recId),
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
    print("resultLeave$result");
    controller.leaveCodes.assignAll(result);
  }

  Future<void> loadEmployee() async {
    final result = await controller.fetchEmployees();
    print("resultEmployee$result");
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
        controller.leaveField.value = false;
        if (!controller.leaveField.value) {
          controller.resetForm();
          return true;
        }

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
            final isLeave = controller.leaveField.value;

            return Text(
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
          return controller.isLoading.value
              ? const SkeletonLoaderPage()
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Obx(() {
                      return Column(
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
                                    widget.leaveRequest?.approvalStatus ??
                                        'N/A',
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
                            onChanged: (code) {
                              controller.selectedLeaveCode.value = code;
                              controller.leaveCodeController.text =
                                  code?.leaveCode ?? '';
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

                          const SizedBox(height: 16),

                          // Reliever
                          _buildConfigurableField(
                            fieldName: 'Delegated authority/Reliever',
                            builder: (isEnabled, isMandatory) {
                              return SearchableMultiColumnDropdownField<
                                Employee
                              >(
                                enabled:
                                    controller.leaveField.value && isEnabled,
                                labelText:
                                    '${AppLocalizations.of(context)!.reliever}${isMandatory ? ' *' : ''}',
                                columnHeaders: [
                                  AppLocalizations.of(context)!.employeeId,
                                  AppLocalizations.of(context)!.name,
                                  AppLocalizations.of(context)!.department,
                                ],
                                items: controller.employees,
                                selectedValue:
                                    controller.selectedReliever.value,
                                searchValue: (emp) => '${emp.id}',
                                displayText: (emp) => emp.firstName,
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
                                      emp?.firstName ?? '';
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
                                            '${emp.firstName}${emp.middleName}${emp.lastName}',
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // Project
                          _buildConfigurableField(
                            fieldName: AppLocalizations.of(context)!.projectId,
                            builder: (isEnabled, isMandatory) {
                              return SearchableMultiColumnDropdownField<
                                Project
                              >(
                                labelText:
                                    '${AppLocalizations.of(context)!.projectId} ${isMandatory ? "*" : ""}',
                                columnHeaders: [
                                  AppLocalizations.of(context)!.projectName,
                                  AppLocalizations.of(context)!.projectId,
                                ],
                                items: controller.project,
                                controller:
                                    controller.projectDropDowncontroller,
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
                                      onPressed: () =>
                                          _selectDateRange(context),
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
                                            Expanded(
                                              child: Text(proj.location),
                                            ),
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
                                enabled:
                                    controller.leaveField.value && isEnabled,
                                labelText:
                                    '${AppLocalizations.of(context)!.notifyingUsers}${isMandatory ? ' *' : ''}',
                                items: controller.employees,
                                selectedValues:
                                    controller.selectedNotifyingUsers,
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
                              return SizedBox(
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
                              );
                            },
                          ),

                          const SizedBox(height: 8),

                          // Comments *
                          TextFormField(
                            controller: controller.commentsController,
                            enabled: controller.leaveField.value,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText:
                                  '${AppLocalizations.of(context)!.comments} *',
                              border: const OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '${AppLocalizations.of(context)!.comments} ${AppLocalizations.of(context)!.fieldRequired}';
                              }
                              return null;
                            },
                            onChanged: controller.leaveField.value
                                ? (value) => controller.comments.value = value
                                : null,
                          ),

                          const SizedBox(height: 16),

                          // Availability During Leave
                          _buildConfigurableField(
                            fieldName: 'Availability during leave',
                            builder: (isEnabled, isMandatory) {
                              return SearchableMultiColumnDropdownField<String>(
                                enabled:
                                    controller.leaveField.value && isEnabled,
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

                          const SizedBox(height: 16),

                          // Out of Office Message
                          _buildConfigurableField(
                            fieldName: 'OutOfOfficeMessage',
                            builder: (isEnabled, isMandatory) {
                              return TextFormField(
                                controller:
                                    controller.outOfOfficeMessageController,
                                enabled:
                                    controller.leaveField.value && isEnabled,
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

                          const SizedBox(height: 16),

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
                                controlAffinity:
                                    ListTileControlAffinity.leading,
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
                                  AppLocalizations.of(
                                    context,
                                  )!.notifyTeamMembers,
                                ),
                                value: controller.notifyTeam.value,
                                onChanged:
                                    controller.leaveField.value && isEnabled
                                    ? (value) => controller.notifyTeam.value =
                                          value ?? false
                                    : null,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                              );
                            },
                          ),

                          const SizedBox(height: 16),
                          const SizedBox(height: 16),

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
                                  onTap: widget.isReadOnly
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
                                      color: Colors.grey.shade50,
                                    ),
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.cloud_upload,
                                          size: 40,
                                        ),
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
                                      itemCount:
                                          controller.uploadedImages.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 8),
                                      itemBuilder: (context, index) {
                                        final file =
                                            controller.uploadedImages[index];

                                        return Stack(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                _openImagePreview(
                                                  context,
                                                  file,
                                                );
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

                                            /// Remove icon
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
                                                          shape:
                                                              BoxShape.circle,
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
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            minimumSize: const Size(0, 32),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
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
                                final date =
                                    DateTime.fromMillisecondsSinceEpoch(
                                      leaveDay.transDate,
                                      isUtc: true,
                                    ).toLocal();

                                return Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      /// Date column
                                      Expanded(
                                        child: Text(
                                          DateFormat(
                                            'dd MMM yyyy',
                                          ).format(date),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      /// Day type column (ALWAYS Expanded)
                                      Expanded(
                                        child: leaveDay.noOfDays == 0
                                            ? Text(
                                                "Non Working Day",
                                                style: TextStyle(fontSize: 14),
                                              )
                                            : SearchableMultiColumnDropdownField<
                                                String
                                              >(
                                                enabled:
                                                    controller
                                                        .leaveField
                                                        .value &&
                                                    !leaveDay.isHoliday,
                                                labelText: AppLocalizations.of(
                                                  context,
                                                )!.dayType,
                                                items: [
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.fullDay,
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.firstHalf,
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.secondHalf,
                                                ],
                                                selectedValue:
                                                    leaveDay.dayType.value,
                                                searchValue: (option) => option,
                                                displayText: (option) => option,
                                                onChanged: (option) {
                                                  leaveDay.dayType.value =
                                                      option ??
                                                      AppLocalizations.of(
                                                        context,
                                                      )!.fullDay;
                                                  controller
                                                      .calculateTotalDays();
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
                                                columnHeaders: const [
                                                  'Day Type',
                                                ],
                                              ),
                                      ),
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

                          const SizedBox(height: 32),

                          // Action Buttons
                          if (widget.leaveRequest != null &&
                              !widget.isReadOnly &&
                              widget.leaveRequest?.stepType?.isNotEmpty == true)
                            _buildApprovalActionButtons(),
                          if (controller.leaveField.value || widget.isReadOnly)
                            _buildActionButtons(),
                          if (widget.status) _buildActionButtons(),

                          if (widget.isReadOnly &&
                              widget.leaveRequest != null &&
                              widget.leaveRequest?.approvalStatus !=
                                  "Approved" &&
                              widget.leaveRequest?.approvalStatus !=
                                  "Cancelled" &&
                              widget.leaveRequest?.approvalStatus != "Pending")
                            _buildViewModeButtons(),

                          const SizedBox(height: 32),
                        ],
                      );
                    }),
                  ),
                );
        }),
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
                    "Leave Partial Cancellation",
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
                    decoration: const InputDecoration(
                      labelText: "Reason for cancellation",
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
                                      DateFormat(
                                        'dd MMM yyyy',
                                      ).format(leaveDay.date),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  /// DAY TYPE
                                  Expanded(
                                    child:
                                        SearchableMultiColumnDropdownField<
                                          String
                                        >(
                                          enabled: !leaveDay.isHoliday,
                                          labelText: "Select",
                                          items: const [
                                            'FullDay',
                                            'FirstHalf',
                                            'SecondHalf',
                                          ],
                                          selectedValue:
                                              leaveDay.dayTypeLeave.value,
                                          searchValue: (o) => o,
                                          displayText: (o) => o,
                                          onChanged: (value) {
                                            if (value == null) return;

                                            leaveDay.dayTypeLeave.value = value;
                                            controller.calculateTotalDays();

                                            /// track modified only
                                            if (value !=
                                                leaveDay.originalDayType) {
                                              controller.modifiedDays[leaveDay
                                                      .recId!] =
                                                  value;
                                            } else {
                                              controller.modifiedDays.remove(
                                                leaveDay.recId,
                                              );
                                            }
                                          },
                                          rowBuilder: (option, _) => Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Text(option),
                                          ),
                                          columnHeaders: const ['Day Type'],
                                        ),
                                  ),
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
                          child: const Text("Cancel"),
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

                            Navigator.pop(context);

                            await controller.submitPartialCancellation(
                              context,
                              leaveReqId: widget.leaveRequest!.recId,
                              reason: reason,
                            );
                          },
                          child: const Text("Save"),
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

    final stepType = widget.leaveRequest!.approvalStatus;
    if (stepType == "Pending") {
      controller.leaveField.value = true;
    }
    if (stepType == null || stepType.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        if (stepType == "Pending")
          Row(
            children: [
              Obx(() {
                final isUpdateLoading =
                    controller.buttonLoaders['update'] ?? false;
                final isUpdateAcceptLoading =
                    controller.buttonLoaders['update_accept'] ?? false;
                final isRejectLoading =
                    controller.buttonLoaders['reject'] ?? false;
                final isAnyLoading = controller.buttonLoaders.values.any(
                  (loading) => loading,
                );

                return Expanded(
                  child: ElevatedButton(
                    onPressed:
                        (isUpdateLoading ||
                            isUpdateAcceptLoading ||
                            isRejectLoading ||
                            isAnyLoading)
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              controller.setButtonLoading('update', true);
                              controller
                                  .submitApprovalLeaveRequest(
                                    context,
                                    false,
                                    widget.leaveRequest!.workitemrecid!,
                                  )
                                  .whenComplete(() {
                                    controller.setButtonLoading(
                                      'update',
                                      false,
                                    );
                                  });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 3, 20, 117),
                    ),
                    child: isUpdateLoading
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
                  ),
                );
              }),

              const SizedBox(width: 12),

              Obx(() {
                final isUpdateLoading =
                    controller.buttonLoaders['update'] ?? false;
                final isUpdateAcceptLoading =
                    controller.buttonLoaders['update_accept'] ?? false;
                final isRejectLoading =
                    controller.buttonLoaders['reject'] ?? false;
                final isAnyLoading = controller.buttonLoaders.values.any(
                  (loading) => loading,
                );

                return Expanded(
                  child: ElevatedButton(
                    onPressed:
                        (isUpdateAcceptLoading ||
                            isUpdateLoading ||
                            isRejectLoading ||
                            isAnyLoading)
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              controller.setButtonLoading(
                                'update_accept',
                                true,
                              );
                              controller
                                  .submitApprovalLeaveRequest(
                                    context,
                                    true,
                                    widget.leaveRequest!.workitemrecid!,
                                  )
                                  .whenComplete(() {
                                    controller.setButtonLoading(
                                      'update_accept',
                                      false,
                                    );
                                  });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 3, 20, 117),
                    ),
                    child: isUpdateAcceptLoading
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
                  ),
                );
              }),
            ],
          ),

        if (stepType == "Pending") const SizedBox(height: 12),

        if (stepType == "Pending")
          Row(
            children: [
              Obx(() {
                final isUpdateLoading =
                    controller.buttonLoaders['update'] ?? false;
                final isUpdateAcceptLoading =
                    controller.buttonLoaders['update_accept'] ?? false;
                final isRejectLoading =
                    controller.buttonLoaders['reject'] ?? false;
                final isAnyLoading = controller.buttonLoaders.values.any(
                  (loading) => loading,
                );

                return Expanded(
                  child: ElevatedButton(
                    onPressed:
                        (isRejectLoading ||
                            isUpdateLoading ||
                            isUpdateAcceptLoading ||
                            isAnyLoading)
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              controller.setButtonLoading('reject', true);
                              showActionPopup(context, "Reject");
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 238, 20, 20),
                    ),
                    child: isRejectLoading
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

              const SizedBox(width: 12),

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

        if (stepType == "Approved")
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

        if (stepType == "Approved")
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
                    controller.chancelButton(context);
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
                    Text(
                      AppLocalizations.of(context)!.action,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (status == "Escalate") ...[
                      Text(
                        '${AppLocalizations.of(context)!.selectUser}*',
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
                          onChanged: (user) {
                            controller.userIdController.text =
                                user?.userId ?? '';
                            controller.selectedUser.value = user;
                          },
                          controller: controller.userIdController,
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
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.comments,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(
                          context,
                        )!.enterCommentHere,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isCommentError ? Colors.red : Colors.grey,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isCommentError ? Colors.red : Colors.teal,
                            width: 2,
                          ),
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
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            controller.closeField();
                            Navigator.pop(context);
                          },
                          child: Text(AppLocalizations.of(context)!.close),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final comment = commentController.text.trim();
                            if (status != "Approve" && comment.isEmpty) {
                              setState(() => isCommentError = true);
                              return;
                            }

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) =>
                                  const Center(child: SkeletonLoaderPage()),
                            );

                            final success = await controller
                                .postApprovalActionLeavel(
                                  context,
                                  workitemrecid: [controller.workitemrecid!],
                                  decision: status,
                                  comment: commentController.text,
                                );

                            if (Navigator.of(
                              context,
                              rootNavigator: true,
                            ).canPop()) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }

                            if (!context.mounted) return;

                            if (success) {
                              controller.setButtonLoading('reject', false);
                              Navigator.pushNamed(
                                context,
                                AppRoutes.leavePendingApprovals,
                              );
                              controller.isApprovalEnable.value = false;
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to submit action'),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(status),
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
          if (controller.leaveField.value &&
              widget.leaveRequest?.approvalStatus == "Rejected" &&
              widget.isReadOnly)
            Obx(() {
              final isResubmitLoading =
                  controller.buttonLoaders['resubmit'] ?? false;
              final isAnyLoading = controller.buttonLoaders.values.any(
                (loading) => loading,
              );

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
                      : () {
                          if (_formKey.currentState!.validate()) {
                            controller.submitLeaveRequest(context, true, true);
                          }
                        },
                  child: isResubmitLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
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

          if (controller.leaveField.value &&
              widget.leaveRequest?.approvalStatus == "Rejected" &&
              widget.isReadOnly)
            Row(
              children: [
                Obx(() {
                  final isUpdateLoading =
                      controller.buttonLoaders['update'] ?? false;
                  final isAnyLoading = controller.buttonLoaders.values.any(
                    (loading) => loading,
                  );

                  return Expanded(
                    child: ElevatedButton(
                      onPressed: (isUpdateLoading || isAnyLoading)
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                controller.submitLeaveRequest(
                                  context,
                                  false,
                                  false,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E7503),
                      ),
                      child: isUpdateLoading
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
                    ),
                  );
                }),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.chancelButton(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                ),
              ],
            )
          else if (controller.leaveField.value &&
              widget.leaveRequest?.approvalStatus == "Created" &&
              widget.isReadOnly) ...[
            /// ---------------- Submit Button ----------------
            Obx(() {
              final isSubmitLoading =
                  controller.buttonLoaders['submit'] ?? false;
              final isAnyLoading = controller.buttonLoaders.values.any(
                (l) => l,
              );

              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: const Color.fromARGB(255, 26, 2, 110),
                  ),
                  onPressed: (isSubmitLoading || isAnyLoading)
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            controller.submitLeaveRequest(context, true, false);
                          }
                        },
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
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              );
            }),

            const SizedBox(height: 12),

            /// ---------------- Save & Cancel Buttons ----------------
            Row(
              children: [
                /// Save Button
                Obx(() {
                  final isSaveLoading =
                      controller.buttonLoaders['saveGE'] ?? false;
                  final isSubmitLoading =
                      controller.buttonLoaders['submit'] ?? false;
                  final isAnyLoading = controller.buttonLoaders.values.any(
                    (l) => l,
                  );

                  return Expanded(
                    child: ElevatedButton(
                      onPressed:
                          (isSaveLoading || isSubmitLoading || isAnyLoading)
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                controller.submitLeaveRequest(
                                  context,
                                  false,
                                  false,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E7503),
                      ),
                      child: isSaveLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context)!.save,
                              style: const TextStyle(color: Colors.white),
                            ),
                    ),
                  );
                }),

                const SizedBox(width: 12),

                /// Cancel Button
                Obx(() {
                  final isAnyLoading = controller.buttonLoaders.values.any(
                    (l) => l,
                  );

                  return Expanded(
                    child: ElevatedButton(
                      onPressed: isAnyLoading
                          ? null
                          : () {
                              controller.chancelButton(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                  );
                }),
              ],
            ),
          ],
          if (widget.isReadOnly &&
              widget.leaveRequest!.approvalStatus == "Approved" &&
              widget.leaveRequest?.leaveCancelId == null)
            Row(
              children: [
                Obx(() {
                  final isLoading = controller.buttonLoaders['cancel'] ?? false;
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
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.red,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Fully Cancel",
                              style: TextStyle(color: Colors.red),
                            ),
                    ),
                  );
                }),
                const SizedBox(width: 12),
                Obx(() {
                  final isLoading = controller.buttonLoaders['cancel'] ?? false;
                  return Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              controller.setButtonLoading('cancel', true);
                              _openPartialCancelPopup(context);
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
                          : const Text(
                              "Partial Cancel",
                              style: TextStyle(color: Colors.red),
                            ),
                    ),
                  );
                }),
              ],
            ),
          if (widget.isReadOnly &&
              widget.leaveRequest!.approvalStatus == "Approved" &&
              widget.leaveRequest?.leaveCancelId?.isNotEmpty == true)
            Row(
              children: [
                Obx(() {
                  final isLoading = controller.buttonLoaders['cancel'] ?? false;
                  return Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              controller.submitExpenseCancel(
                                contextRecId: widget.leaveRequest!.recId,
                              );
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
                          : const Text(
                              " Cancel",
                              style: TextStyle(color: Colors.red),
                            ),
                    ),
                  );
                }),
                const SizedBox(width: 12),
                Obx(() {
                  final isLoading = controller.buttonLoaders['cancel'] ?? false;
                  return Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              controller.setButtonLoading('cancel', false);
                              controller.resetForm();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          156,
                          155,
                          155,
                        ),
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
                          : const Text(
                              "Close",
                              style: TextStyle(
                                color: Color.fromARGB(255, 10, 10, 10),
                              ),
                            ),
                    ),
                  );
                }),
              ],
            ),
          if (widget.isReadOnly &&
              widget.leaveRequest!.approvalStatus == "Approved" &&
              widget.leaveRequest?.leaveCancelId == null)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.resetForm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),

          if (widget.isReadOnly &&
              widget.leaveRequest?.approvalStatus == "Pending")
            Row(
              children: [
                Obx(() {
                  final isLoading = controller.buttonLoaders['cancel'] ?? false;
                  return Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              controller.setButtonLoading('cancel', true);
                              controller
                                  .leavecancelExpense(
                                    context,
                                    widget.leaveRequest!.recId.toString(),
                                  )
                                  .whenComplete(() {
                                    controller.setButtonLoading(
                                      'cancel',
                                      false,
                                    );
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
                      controller.chancelButton(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 28),
        ] else ...[
          Obx(
            () => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isButtonLoading('submit')
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          controller.submitLeaveRequest(context, true, false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: const Color.fromARGB(255, 29, 1, 128),
                ),
                child: controller.isButtonLoading('submit')
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              // Save as Draft Button
              Expanded(
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isButtonLoading('save')
                        ? null
                        : () {
                            controller.submitLeaveRequest(
                              context,
                              false,
                              false,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF1E7503),
                    ),
                    child: controller.isButtonLoading('saveDraft')
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.save,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Cancel Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    controller.resetForm();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.grey,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
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
            "Leave Full Cancellation",
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
                decoration: const InputDecoration(
                  labelText: "Reason for cancellation",
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
              child: const Text("Cancel"),
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
                Navigator.pop(context);
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
              child: const Text("Save"),
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
void initializeControllers() {
  Get.put(Controller());
}
