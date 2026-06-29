import 'dart:async';
import 'dart:io';
import 'package:diginexa/core/comman/widgets/loaderbutton.dart';
import 'package:diginexa/core/comman/widgets/permissionHelper.dart';
import 'package:diginexa/core/constant/Parames/colors.dart' show AppColors;
import 'package:diginexa/core/constant/Parames/params.dart' show Params;
import 'package:diginexa/core/utils.dart';
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

  RxList<UpcomingHoliday> upcomingHolidays = <UpcomingHoliday>[].obs;

  RxList<LastAppliedLeave> lastAppliedLeaves = <LastAppliedLeave>[].obs;
  late Future<List<ExpenseHistory>> historyFuture;

  var isAllowPastDate = true.obs;
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
      controller.loadAllCustomFieldValues();
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
        controller.loadLeaveAnalytics(DateTime.now()),
        loadEmployee(),
        loadLeaveAnalytics(),
        controller.fetchUsers(),
      ]);
      await controller.mergeLeaveBalances();

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
    } catch (e, stack) {
      debugPrint("Init Leave Screen Error: $e");
      debugPrint('Stack: $stack');
    } finally {
      controller.isLoading.value = false;
    }
  }

  Future<void> loadLeaveAnalytics() async {
    final result = await controller.fetchLeaveAnalytics(
      Params.employeeId,
      Params.userToken,
    );

    if (result != null) {
      leaveAnalyticsCards.assignAll(result.leaveCodeAnalytics);

      upcomingHolidays.assignAll(result.upcomingHolidays);

      lastAppliedLeaves.assignAll(result.lastAppliedLeaves);
    }
  }

  Future<void> loadEmployee() async {
    final result = await controller.fetchEmployees();

    controller.employees.assignAll(result);
  }

  Future<void> _selectDateRange(BuildContext context) async {
    /// Validate leave code is selected first
    if (controller.leaveCodeController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please select a leave code first",
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      return;
    }

    print("isAllowedPastDates: ${controller.isAllowedPastDates.value}");

    // For the date picker, create dates in LOCAL timezone (not UTC)
    final todayOrg = todayInOrgTimezone();
    final todayForPicker = DateTime(
      todayOrg.year,
      todayOrg.month,
      todayOrg.day,
    );
    print("todayForPicker: $todayForPicker");

    final firstDate = controller.isAllowedPastDates.value
        ? DateTime(2023, 1, 1)
        : todayForPicker;

    // Get existing dates - convert from UTC to LOCAL for the picker
    DateTime validStartDate;
    DateTime validEndDate;

    if (controller.startDate.value != null) {
      // Convert stored UTC to local for picker display
      final offsetMs = getTimezoneOffsetMs();
      final orgLocalDate = DateTime.fromMillisecondsSinceEpoch(
        controller.startDate.value!.millisecondsSinceEpoch + offsetMs,
        isUtc: true,
      );
      validStartDate = DateTime(
        orgLocalDate.year,
        orgLocalDate.month,
        orgLocalDate.day,
      );
    } else {
      validStartDate = todayForPicker;
    }

    if (controller.endDate.value != null) {
      final offsetMs = getTimezoneOffsetMs();
      final orgLocalDate = DateTime.fromMillisecondsSinceEpoch(
        controller.endDate.value!.millisecondsSinceEpoch + offsetMs,
        isUtc: true,
      );
      validEndDate = DateTime(
        orgLocalDate.year,
        orgLocalDate.month,
        orgLocalDate.day,
      );
    } else {
      validEndDate = todayForPicker;
    }

    // Ensure start date is not after end date
    if (validStartDate.isAfter(validEndDate)) {
      final temp = validStartDate;
      validStartDate = validEndDate;
      validEndDate = temp;
    }

    final initialDateRange = DateTimeRange(
      start: validStartDate,
      end: validEndDate,
    );

    try {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: firstDate,
        lastDate: DateTime(2030, 12, 31),
        initialDateRange: initialDateRange,
        initialEntryMode: DatePickerEntryMode.calendar,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.gradientEnd,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        try {
          // Store picked dates as UTC (convert local to UTC)
          final startDateUtc = DateTime.utc(
            picked.start.year,
            picked.start.month,
            picked.start.day,
          );
          final endDateUtc = DateTime.utc(
            picked.end.year,
            picked.end.month,
            picked.end.day,
          );

          // Store as UTC
          if (startDateUtc.isAfter(endDateUtc)) {
            controller.startDate.value = endDateUtc;
            controller.endDate.value = startDateUtc;
          } else {
            controller.startDate.value = startDateUtc;
            controller.endDate.value = endDateUtc;
          }
          final pickedStart = DateTime(
            picked.start.year,
            picked.start.month,
            picked.start.day,
          );
          final pickedEnd = DateTime(
            picked.end.year,
            picked.end.month,
            picked.end.day,
          );

          if (!controller.isAllowedPastDates.value) {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);

            // Check if start date is today or before today (not allowed)
            if (pickedStart.isBefore(today) ||
                pickedStart.isAtSameMomentAs(today)) {
              isAllowPastDate.value = false;

              return;
            }

            // Check if end date is today or before today (not allowed)
            if (pickedEnd.isBefore(today) ||
                pickedEnd.isAtSameMomentAs(today)) {
              isAllowPastDate.value = false;

              return;
            }

            // ✅ Dates are valid (tomorrow or future)
            isAllowPastDate.value = true;
          } else {
            // ✅ Past dates are allowed
            isAllowPastDate.value = true;
          }
          // Update display using formatDate (converts UTC to org-local correctly)
          controller.fromDateController.text = formatDate(
            controller.startDate.value!,
          );
          controller.toDateController.text = formatDate(
            controller.endDate.value!,
          );
          controller.updateDatesController();
          // Load leave analytics
          await controller.loadLeaveAnalytics(controller.startDate.value);

          // Create leave transactions
          if (controller.leaveCodeController.text.isNotEmpty) {
            await controller.createLeaveTransactions(
              employeeId: Params.employeeId,
              fromDate: toStartOfDayUtc(controller.startDate.value!),
              toDate: toEndOfDayUtc(controller.endDate.value!),
              leaveCode: controller.leaveCodeController.text,
            );
          }

          controller.customFields.refresh();
        } catch (e) {
          print("Error in date range selection: $e");
          Fluttertoast.showToast(
            msg: "Error updating leave dates: ${e.toString()}",
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        } finally {
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      }
    } catch (e) {
      print("Date picker error: $e");
      Fluttertoast.showToast(
        msg: "Failed to open date picker",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
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
                        SizedBox(
                          height: 150,
                          child: Obx(() {
                            final isLoading =
                                controller.isLoadingLeave.value ||
                                controller.isLoading.value;

                            if (isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final hasHolidays = upcomingHolidays.isNotEmpty;
                            final hasLeaves = lastAppliedLeaves.isNotEmpty;

                            final totalCount =
                                leaveAnalyticsCards.length +
                                (hasHolidays ? 1 : 0) +
                                (hasLeaves ? 1 : 0);

                            if (totalCount == 0) {
                              return const Center(child: Text("No Data Found"));
                            }

                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: totalCount,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                // 🔹 Leave Analytics Cards
                                if (index < leaveAnalyticsCards.length) {
                                  final card = leaveAnalyticsCards[index];
                                  return _buildCard(card);
                                }

                                int remaining =
                                    index - leaveAnalyticsCards.length;

                                // 🔹 Single card containing ALL upcoming holidays
                                if (hasHolidays) {
                                  if (remaining == 0) {
                                    return _buildHolidayCard(upcomingHolidays);
                                  }
                                  remaining -= 1;
                                }

                                // 🔹 Single card containing ALL applied leaves
                                return _buildLastLeaveCard(lastAppliedLeaves);
                              },
                            );
                          }),
                        ),
                        const SizedBox(height: 10),
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
                          // In your widget
                          onChanged: (code) async {
                            if (code == null) return;

                            controller.selectedLeaveCode.value = code;
                            controller.leaveCodeController.text =
                                code.leaveCode;
                            controller.isAllowedPastDates.value =
                                code.isPastAllowed;
                            // Direct check: If past dates not allowed, validate selected dates
                            if (!code.isPastAllowed) {
                              if (controller.startDate.value != null &&
                                  controller.endDate.value != null) {
                                final now = DateTime.now();
                                final today = DateTime(
                                  now.year,
                                  now.month,
                                  now.day,
                                );

                                // Normalize dates
                                final startDateOnly = DateTime(
                                  controller.startDate.value!.year,
                                  controller.startDate.value!.month,
                                  controller.startDate.value!.day,
                                );
                                final endDateOnly = DateTime(
                                  controller.endDate.value!.year,
                                  controller.endDate.value!.month,
                                  controller.endDate.value!.day,
                                );

                                // Check if date is today or past (NOT after today)
                                if (!startDateOnly.isAfter(today) ||
                                    !endDateOnly.isAfter(today)) {
                                  isAllowPastDate.value = false;

                                  // controller.startDate.value = null;
                                  // controller.endDate.value = null;
                                  // controller.datesController.text = '';
                                  return;
                                }
                              }
                              isAllowPastDate.value = true;
                            } else {
                              isAllowPastDate.value = true;
                            }

                            // if (!code.isPastAllowed) {
                            //   isAllowPastDate.value = true;
                            // } else {
                            //   isAllowPastDate.value = false;
                            // }
                            // Validate
                            if (controller.startDate.value == null ||
                                controller.endDate.value == null) {
                              Get.snackbar(
                                'Error',
                                'Please select start and end dates',
                              );
                              return;
                            }
                            print(
                              "isAllowedPastDates${controller.isAllowedPastDates.value}$isAllowPastDate",
                            );
                            // Convert to org-local timezone
                            final offsetMs = getTimezoneOffsetMs();

                            final startDateOrg =
                                DateTime.fromMillisecondsSinceEpoch(
                                  controller
                                          .startDate
                                          .value!
                                          .millisecondsSinceEpoch +
                                      offsetMs,
                                  isUtc: true,
                                );

                            final endDateOrg =
                                DateTime.fromMillisecondsSinceEpoch(
                                  controller
                                          .endDate
                                          .value!
                                          .millisecondsSinceEpoch +
                                      offsetMs,
                                  isUtc: true,
                                );

                            // Get UTC milliseconds for API
                            final fromDateMs = toStartOfDayUtc(startDateOrg);
                            final toDateMs = toEndOfDayUtc(endDateOrg);

                            // Debug
                            print("Start Date Org: $startDateOrg");
                            print("End Date Org: $endDateOrg");
                            print("From Date MS: $fromDateMs");
                            print("To Date MS: $toDateMs");

                            // Call API
                            await controller.createLeaveTransactions(
                              employeeId: Params.employeeId,
                              fromDate: fromDateMs,
                              toDate: toDateMs,
                              leaveCode: code.leaveCode,
                            );
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
                            errorText: isAllowPastDate.value
                                ? null
                                : "Start Date must be greater than today", // Returns String? (null when no error)
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
                            } else if (!isAllowPastDate.value) {
                              return "Start Date must be greater than today";
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
                                    // controller.fetchPerDiemRates();
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
                            if (controller.commentsController.text.isEmpty) {
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
                                      if (controller
                                          .outOfOfficeMessageController
                                          .text
                                          .isEmpty) {
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
                        const SizedBox(height: 6),
                        Obx(() {
                          final bool isEnabled = controller
                              .leaveField
                              .value; // Get enabled state once

                          return Column(
                            children: controller.customFields
                                .where(
                                  (field) =>
                                      field['ObjectName'] == "LeaveRequisition",
                                )
                                .map((field) {
                                  final String label =
                                      field['FieldLabel'] ?? field['FieldName'];
                                  final bool isMandatory =
                                      field['IsMandatory'] ?? false;

                                  // Populate default value if exists and not already set
                                  if (field['DefaultValue'] != null &&
                                      (field['EnteredValue'] == null ||
                                          (field['EnteredValue'] is String &&
                                              field['EnteredValue'].isEmpty))) {
                                    field['EnteredValue'] =
                                        field['DefaultValue'];
                                  }

                                  Widget inputField;

                                  // Handle SystemList, List, and CustomList
                                  if (field['FieldType'] == 'List' ||
                                      field['FieldType'] == 'CustomList' ||
                                      field['FieldType'] == 'SystemList') {
                                    List<CustomDropdownValue> options = [];
                                    if (field['Options'] != null &&
                                        field['Options'] is List) {
                                      options = List<CustomDropdownValue>.from(
                                        field['Options'],
                                      );
                                    }

                                    field['_controller'] ??=
                                        TextEditingController();
                                    final TextEditingController
                                    fieldController = field['_controller'];

                                    CustomDropdownValue? selectedValue =
                                        field['SelectedValue'];

                                    if (selectedValue == null &&
                                        field['DefaultValue'] != null) {
                                      final matches = options.where(
                                        (opt) =>
                                            opt.valueId ==
                                                field['DefaultValue'] ||
                                            opt.valueName ==
                                                field['DefaultValue'],
                                      );
                                      selectedValue = matches.isNotEmpty
                                          ? matches.first
                                          : null;

                                      if (selectedValue != null) {
                                        field['SelectedValue'] = selectedValue;
                                        field['EnteredValue'] =
                                            selectedValue.valueId;
                                      }
                                    }

                                    fieldController.text =
                                        selectedValue?.valueName ??
                                        field['DefaultValue']?.toString() ??
                                        '';

                                    if (selectedValue == null &&
                                        field['DefaultValue'] != null) {
                                      selectedValue = CustomDropdownValue(
                                        valueId: field['DefaultValue']
                                            .toString(),
                                        valueName: field['DefaultValue']
                                            .toString(),
                                      );
                                      final alreadyExists = options.any(
                                        (opt) =>
                                            opt.valueId ==
                                            selectedValue!.valueId,
                                      );
                                      if (!alreadyExists) {
                                        options = [selectedValue, ...options];
                                      }
                                      field['SelectedValue'] = selectedValue;
                                      field['EnteredValue'] =
                                          selectedValue.valueId;
                                    }

                                    inputField =
                                        SearchableMultiColumnDropdownField<
                                          CustomDropdownValue
                                        >(
                                          labelText:
                                              '$label${isMandatory ? " *" : ""}',
                                          items: options,
                                          selectedValue: selectedValue,
                                          searchValue: (val) => val.valueName,
                                          displayText: (val) => val.valueName,
                                          controller: fieldController,
                                          enabled:
                                              isEnabled, // Add enabled property
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
                                                      child: Text(val.valueId),
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
                                            if (!isEnabled)
                                              return; // Check if enabled
                                            field['SelectedValue'] = val;
                                            field['EnteredValue'] =
                                                val?.valueId;
                                            field['Error'] = null;
                                            fieldController.text =
                                                val?.valueName ?? '';
                                            controller.customFields.refresh();
                                          },
                                        );
                                  }
                                  // Checkbox rendering
                                  else if (field['FieldType'] == 'Checkbox') {
                                    bool checkboxValue =
                                        field['EnteredValue'] ?? false;
                                    if (field['DefaultValue'] != null &&
                                        field['EnteredValue'] == null) {
                                      checkboxValue =
                                          field['DefaultValue'] == true ||
                                          field['DefaultValue'] == 'true';
                                      field['EnteredValue'] = checkboxValue;
                                    }

                                    inputField = CheckboxListTile(
                                      title: Text(
                                        '$label${isMandatory ? " *" : ""}',
                                      ),
                                      value: checkboxValue,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      contentPadding: EdgeInsets.zero,
                                      onChanged: isEnabled
                                          ? (bool? val) {
                                              // Only allow change if enabled
                                              field['EnteredValue'] =
                                                  val ?? false;
                                              field['Error'] = null;
                                              controller.customFields.refresh();
                                            }
                                          : null,
                                    );
                                  }
                                  // Date and DateTime rendering
                                  else if (field['FieldType'] == 'Date' ||
                                      field['FieldType'] == 'Date&Time') {
                                    final bool isDateTime =
                                        field['FieldType'] == 'Date&Time';
                                    DateTime? currentValue;

                                    if (field['EnteredValue'] != null) {
                                      if (field['EnteredValue'] is DateTime) {
                                        currentValue = field['EnteredValue'];
                                      } else if (field['EnteredValue']
                                          is String) {
                                        try {
                                          currentValue = DateTime.parse(
                                            field['EnteredValue'],
                                          );
                                        } catch (e) {
                                          try {
                                            List<String> dateFormats = [
                                              'dd/MM/yyyy',
                                              'MM/dd/yyyy',
                                              'yyyy-MM-dd',
                                              'dd-MM-yyyy',
                                            ];
                                            for (var format in dateFormats) {
                                              try {
                                                currentValue = DateFormat(
                                                  format,
                                                ).parse(field['EnteredValue']);
                                                break;
                                              } catch (_) {}
                                            }
                                          } catch (_) {
                                            currentValue = null;
                                          }
                                        }
                                      }
                                    }

                                    if (currentValue == null &&
                                        field['DefaultValue'] != null) {
                                      if (field['DefaultValue'] is DateTime) {
                                        currentValue = field['DefaultValue'];
                                      } else if (field['DefaultValue']
                                          is String) {
                                        try {
                                          currentValue = DateTime.parse(
                                            field['DefaultValue'],
                                          );
                                        } catch (e) {
                                          try {
                                            List<String> dateFormats = [
                                              'dd/MM/yyyy',
                                              'MM/dd/yyyy',
                                              'yyyy-MM-dd',
                                              'dd-MM-yyyy',
                                            ];
                                            for (var format in dateFormats) {
                                              try {
                                                currentValue = DateFormat(
                                                  format,
                                                ).parse(field['DefaultValue']);
                                                break;
                                              } catch (_) {}
                                            }
                                          } catch (_) {
                                            currentValue = null;
                                          }
                                        }
                                      }
                                    }

                                    if (currentValue != null) {
                                      field['EnteredValue'] = currentValue;
                                    }

                                    String formatDateValue(DateTime date) {
                                      return DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(date);
                                    }

                                    String formatDateTimeValue(
                                      DateTime dateTime,
                                    ) {
                                      return DateFormat(
                                        'dd/MM/yyyy hh:mm a',
                                      ).format(dateTime);
                                    }

                                    inputField = TextFormField(
                                      readOnly: true,
                                      enabled:
                                          isEnabled, // Add enabled property
                                      controller: TextEditingController(
                                        text: currentValue != null
                                            ? isDateTime
                                                  ? formatDateTimeValue(
                                                      currentValue,
                                                    )
                                                  : formatDateValue(
                                                      currentValue,
                                                    )
                                            : '',
                                      ),
                                      decoration: InputDecoration(
                                        labelText:
                                            '$label${isMandatory ? " *" : ""}',
                                        border: const OutlineInputBorder(),
                                        errorText: field['Error'],
                                        suffixIcon: Icon(
                                          Icons.calendar_today,
                                          color: isEnabled ? null : Colors.grey,
                                        ),
                                      ),
                                      onTap: isEnabled
                                          ? () async {
                                              // Only allow tap if enabled
                                              final DateTime? pickedDate =
                                                  await showDatePicker(
                                                    context: context,
                                                    initialDate:
                                                        currentValue ??
                                                        DateTime.now(),
                                                    firstDate: DateTime(2000),
                                                    lastDate: DateTime(2100),
                                                  );
                                              if (pickedDate == null) return;

                                              if (isDateTime) {
                                                final TimeOfDay?
                                                pickedTime = await showTimePicker(
                                                  context: context,
                                                  initialTime:
                                                      currentValue != null
                                                      ? TimeOfDay.fromDateTime(
                                                          currentValue!,
                                                        )
                                                      : TimeOfDay.now(),
                                                );
                                                if (pickedTime == null) return;
                                                currentValue = DateTime(
                                                  pickedDate.year,
                                                  pickedDate.month,
                                                  pickedDate.day,
                                                  pickedTime.hour,
                                                  pickedTime.minute,
                                                );
                                              } else {
                                                currentValue = pickedDate;
                                              }
                                              field['EnteredValue'] =
                                                  currentValue;
                                              field['Error'] = null;
                                              controller.customFields.refresh();
                                            }
                                          : null,
                                      validator: (value) {
                                        if (isMandatory &&
                                            field['EnteredValue'] == null) {
                                          return '$label is required';
                                        }
                                        return null;
                                      },
                                    );
                                  }
                                  // LongInteger validation
                                  else if (field['FieldType'] ==
                                      'LongInteger') {
                                    inputField = TextFormField(
                                      enabled:
                                          isEnabled, // Add enabled property
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^-?\d*'),
                                        ),
                                      ],
                                      initialValue:
                                          field['EnteredValue']?.toString() ??
                                          '',
                                      decoration: InputDecoration(
                                        labelText:
                                            '$label${isMandatory ? " *" : ""}',
                                        border: const OutlineInputBorder(),
                                        errorText: field['Error'],
                                      ),
                                      onChanged: isEnabled
                                          ? (value) {
                                              if (value.isEmpty) {
                                                field['EnteredValue'] = null;
                                              } else {
                                                try {
                                                  field['EnteredValue'] =
                                                      int.parse(value);
                                                  field['Error'] = null;
                                                } catch (e) {
                                                  field['Error'] =
                                                      'Please enter a valid whole number';
                                                }
                                              }
                                              controller.customFields.refresh();
                                            }
                                          : null,
                                      validator: (value) {
                                        if (isMandatory &&
                                            (value == null ||
                                                value.trim().isEmpty)) {
                                          return '$label is required';
                                        }
                                        if (value != null && value.isNotEmpty) {
                                          if (!RegExp(
                                            r'^-?\d+$',
                                          ).hasMatch(value)) {
                                            return 'Please enter a valid integer (whole number)';
                                          }
                                        }
                                        return null;
                                      },
                                    );
                                  }
                                  // Decimal validation
                                  else if (field['FieldType'] == 'Decimal') {
                                    inputField = TextFormField(
                                      enabled:
                                          isEnabled, // Add enabled property
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^-?\d*\.?\d*'),
                                        ),
                                      ],
                                      initialValue:
                                          field['EnteredValue']?.toString() ??
                                          '',
                                      decoration: InputDecoration(
                                        labelText:
                                            '$label${isMandatory ? " *" : ""}',
                                        border: const OutlineInputBorder(),
                                        errorText: field['Error'],
                                      ),
                                      onChanged: isEnabled
                                          ? (value) {
                                              if (value.isEmpty) {
                                                field['EnteredValue'] = null;
                                              } else {
                                                try {
                                                  field['EnteredValue'] =
                                                      double.parse(value);
                                                  field['Error'] = null;
                                                } catch (e) {
                                                  field['Error'] =
                                                      'Please enter a valid decimal number';
                                                }
                                              }
                                              controller.customFields.refresh();
                                            }
                                          : null,
                                      validator: (value) {
                                        if (isMandatory &&
                                            (value == null ||
                                                value.trim().isEmpty)) {
                                          return '$label is required';
                                        }
                                        if (value != null && value.isNotEmpty) {
                                          if (!RegExp(
                                            r'^-?\d*\.?\d+$',
                                          ).hasMatch(value)) {
                                            return 'Please enter a valid decimal number';
                                          }
                                        }
                                        return null;
                                      },
                                    );
                                  }
                                  // Email validation
                                  else if (field['FieldType'] == 'Email') {
                                    inputField = TextFormField(
                                      enabled:
                                          isEnabled, // Add enabled property
                                      keyboardType: TextInputType.emailAddress,
                                      initialValue: field['EnteredValue'] ?? '',
                                      decoration: InputDecoration(
                                        labelText:
                                            '$label${isMandatory ? " *" : ""}',
                                        border: const OutlineInputBorder(),
                                        errorText: field['Error'],
                                        suffixIcon: const Icon(
                                          Icons.email_outlined,
                                        ),
                                      ),
                                      onChanged: isEnabled
                                          ? (value) {
                                              field['EnteredValue'] = value;
                                              field['Error'] = null;
                                              controller.customFields.refresh();
                                            }
                                          : null,
                                      validator: (value) {
                                        if (isMandatory &&
                                            (value == null ||
                                                value.trim().isEmpty)) {
                                          return '$label is required';
                                        }
                                        if (value != null && value.isNotEmpty) {
                                          final emailRegex = RegExp(
                                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                          );
                                          if (!emailRegex.hasMatch(value)) {
                                            return 'Enter a valid email address (e.g., user@example.com)';
                                          }
                                        }
                                        return null;
                                      },
                                    );
                                  }
                                  // Mobile Number validation
                                  else if (field['FieldType'] ==
                                      'MobileNumber') {
                                    inputField = TextFormField(
                                      enabled:
                                          isEnabled, // Add enabled property
                                      keyboardType: TextInputType.phone,
                                      initialValue: field['EnteredValue'] ?? '',
                                      decoration: InputDecoration(
                                        labelText:
                                            '$label${isMandatory ? " *" : ""}',
                                        border: const OutlineInputBorder(),
                                        errorText: field['Error'],
                                        suffixIcon: const Icon(
                                          Icons.phone_outlined,
                                        ),
                                      ),
                                      onChanged: isEnabled
                                          ? (value) {
                                              field['EnteredValue'] = value;
                                              field['Error'] = null;
                                              controller.customFields.refresh();
                                            }
                                          : null,
                                      validator: (value) {
                                        if (isMandatory &&
                                            (value == null ||
                                                value.trim().isEmpty)) {
                                          return '$label is required';
                                        }
                                        if (value != null && value.isNotEmpty) {
                                          final phoneRegex = RegExp(
                                            r'^[\+]?[0-9]{1,4}[\s\-]?[0-9]{6,12}$',
                                          );
                                          if (!phoneRegex.hasMatch(
                                            value.trim(),
                                          )) {
                                            return 'Enter a valid mobile number with country code (e.g., +91 9876543210)';
                                          }
                                        }
                                        return null;
                                      },
                                    );
                                  }
                                  // URL validation
                                  else if (field['FieldType'] == 'URL') {
                                    inputField = TextFormField(
                                      enabled:
                                          isEnabled, // Add enabled property
                                      keyboardType: TextInputType.url,
                                      initialValue: field['EnteredValue'] ?? '',
                                      decoration: InputDecoration(
                                        labelText:
                                            '$label${isMandatory ? " *" : ""}',
                                        border: const OutlineInputBorder(),
                                        errorText: field['Error'],
                                        suffixIcon: const Icon(
                                          Icons.link_outlined,
                                        ),
                                      ),
                                      onChanged: isEnabled
                                          ? (value) {
                                              field['EnteredValue'] = value;
                                              field['Error'] = null;
                                              controller.customFields.refresh();
                                            }
                                          : null,
                                      validator: (value) {
                                        if (isMandatory &&
                                            (value == null ||
                                                value.trim().isEmpty)) {
                                          return '$label is required';
                                        }
                                        if (value != null && value.isNotEmpty) {
                                          final urlRegex = RegExp(
                                            r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
                                            caseSensitive: false,
                                          );
                                          if (!urlRegex.hasMatch(value)) {
                                            return 'Enter a valid URL (e.g., https://example.com)';
                                          }
                                        }
                                        return null;
                                      },
                                    );
                                  }
                                  // Percentage field
                                  else if (field['FieldType'] == 'Percent') {
                                    inputField = TextFormField(
                                      enabled:
                                          isEnabled, // Add enabled property
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*\.?\d*'),
                                        ),
                                      ],
                                      initialValue:
                                          field['EnteredValue']?.toString() ??
                                          '',
                                      decoration: InputDecoration(
                                        labelText:
                                            '$label${isMandatory ? " *" : ""}',
                                        border: const OutlineInputBorder(),
                                        errorText: field['Error'],
                                        suffixText: '%',
                                        suffixStyle: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      onChanged: isEnabled
                                          ? (value) {
                                              if (value.isEmpty) {
                                                field['EnteredValue'] = null;
                                              } else {
                                                try {
                                                  double percentage =
                                                      double.parse(value);
                                                  if (percentage >= 0 &&
                                                      percentage <= 100) {
                                                    field['EnteredValue'] =
                                                        percentage;
                                                    field['Error'] = null;
                                                  } else {
                                                    field['Error'] =
                                                        'Percentage must be between 0 and 100';
                                                  }
                                                } catch (e) {
                                                  field['Error'] =
                                                      'Please enter a valid percentage';
                                                }
                                              }
                                              controller.customFields.refresh();
                                            }
                                          : null,
                                      validator: (value) {
                                        if (isMandatory &&
                                            (value == null ||
                                                value.trim().isEmpty)) {
                                          return '$label is required';
                                        }
                                        if (value != null && value.isNotEmpty) {
                                          try {
                                            double percentage = double.parse(
                                              value,
                                            );
                                            if (percentage < 0 ||
                                                percentage > 100) {
                                              return 'Percentage must be between 0 and 100';
                                            }
                                          } catch (e) {
                                            return 'Please enter a valid percentage number';
                                          }
                                        }
                                        return null;
                                      },
                                    );
                                  }
                                  // Amount field
                                  else if (field['FieldType'] == 'Amount') {
                                    inputField = TextFormField(
                                      enabled:
                                          isEnabled, // Add enabled property
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*\.?\d*'),
                                        ),
                                      ],
                                      initialValue:
                                          field['EnteredValue']?.toString() ??
                                          '',
                                      decoration: InputDecoration(
                                        labelText:
                                            '$label${isMandatory ? " *" : ""}',
                                        border: const OutlineInputBorder(),
                                        errorText: field['Error'],
                                        prefixText: '\$ ',
                                        prefixStyle: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      onChanged: isEnabled
                                          ? (value) {
                                              if (value.isEmpty) {
                                                field['EnteredValue'] = null;
                                              } else {
                                                try {
                                                  field['EnteredValue'] =
                                                      double.parse(value);
                                                  field['Error'] = null;
                                                } catch (e) {
                                                  field['Error'] =
                                                      'Please enter a valid amount';
                                                }
                                              }
                                              controller.customFields.refresh();
                                            }
                                          : null,
                                      validator: (value) {
                                        if (isMandatory &&
                                            (value == null ||
                                                value.trim().isEmpty)) {
                                          return '$label is required';
                                        }
                                        if (value != null && value.isNotEmpty) {
                                          if (!RegExp(
                                            r'^\d*\.?\d+$',
                                          ).hasMatch(value)) {
                                            return 'Please enter a valid amount';
                                          }
                                        }
                                        return null;
                                      },
                                    );
                                  }
                                  // Default text field
                                  else {
                                    inputField = TextFormField(
                                      enabled:
                                          isEnabled, // Add enabled property
                                      keyboardType: TextInputType.text,
                                      initialValue: field['EnteredValue'] ?? '',
                                      decoration: InputDecoration(
                                        labelText:
                                            '$label${isMandatory ? " *" : ""}',
                                        border: const OutlineInputBorder(),
                                        errorText: field['Error'],
                                      ),
                                      onChanged: isEnabled
                                          ? (value) {
                                              field['EnteredValue'] = value;
                                              field['Error'] = null;
                                              controller.customFields.refresh();
                                            }
                                          : null,
                                      validator: (value) {
                                        if (isMandatory &&
                                            (value == null ||
                                                value.trim().isEmpty)) {
                                          return '$label is required';
                                        }
                                        return null;
                                      },
                                    );
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
                              final date =
                                  DateTime.fromMillisecondsSinceEpoch(
                                    leaveDay.transDate,
                                    isUtc: true,
                                  ).add(
                                    Duration(
                                      milliseconds: getTimezoneOffsetMs(),
                                    ),
                                  );
                              return Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    /// Date column
                                    Expanded(
                                      child: Text(
                                        DateFormat(
                                          controller.selectedFormat?.key ??
                                              'dd/MM/yyyy',
                                        ).format(date),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    /// Day type column (ALWAYS Expanded)
                                    // In the leaveDays Obx builder, replace the items list:
                                    Expanded(
                                      child: leaveDay.noOfDays == 0
                                          ? const Text(
                                              "Non Working Day",
                                              style: TextStyle(fontSize: 12),
                                            )
                                          : Obx(() {
                                              // Build items based on AllowHalfDay from selected leave code
                                              final allowHalfDay =
                                                  controller
                                                      .selectedLeaveCode
                                                      .value
                                                      ?.allowHalfDay ??
                                                  true;

                                              final dayTypeItems = allowHalfDay
                                                  ? [
                                                      'Full Day',
                                                      'First Half',
                                                      'Second Half',
                                                    ]
                                                  : ['Full Day'];

                                              // If current value is half day but not allowed, reset to Full Day
                                              if (!allowHalfDay &&
                                                  (leaveDay.dayType.value ==
                                                          'First Half' ||
                                                      leaveDay.dayType.value ==
                                                          'Second Half')) {
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                      leaveDay.dayType.value =
                                                          'Full Day';
                                                    });
                                              }

                                              return SearchableMultiColumnDropdownField<
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
                                                items:
                                                    dayTypeItems, // ← dynamic list
                                                selectedValue:
                                                    leaveDay.dayType.value,
                                                searchValue: (option) => option,
                                                displayText: (option) => option,
                                                onChanged: (option) {
                                                  leaveDay.dayType.value =
                                                      option!;
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
                                              );
                                            }),
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

  Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  Widget _buildCard(LeaveAnalytics data) {
    final percent = data.totalLeaves == 0
        ? 0.0
        : (data.leaveBalance / data.totalLeaves).clamp(0.0, 1.0);

    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.remaining,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  data.leaveCode,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 70,
                width: 70,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 7,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(
                    hexToColor(data.leaveCodeColor),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.leaveBalance.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${AppLocalizations.of(context)!.outOf} ${data.totalLeaves}',
                    style: const TextStyle(fontSize: 8),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHolidayCard(List<UpcomingHoliday> holidays) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.orange.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Upcoming Holidays",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: holidays.length,
              separatorBuilder: (_, __) => const Divider(height: 10),
              itemBuilder: (context, i) {
                final holiday = holidays[i];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            holiday.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            holiday.holidayType,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM').format(holiday.date),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastLeaveCard(List<LastAppliedLeave> leaves) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Applied Leaves",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: leaves.length,
              separatorBuilder: (_, __) => const Divider(height: 10),
              itemBuilder: (context, i) {
                final leave = leaves[i];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            leave.leaveId,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Duration: ${leave.duration}",
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      leave.approvalStatus,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color getIndicatorColor(String description) {
    switch (description) {
      case 'Total Team Members':
        return Colors.deepPurple;

      case 'Total leaves':
        return Colors.orange;

      case 'Average Team Leaves':
        return Colors.green;

      case 'Pending':
        return Colors.amber;

      case 'Approved':
        return Colors.green;

      case 'Draft':
        return Colors.blueGrey;

      case 'Cancelled':
        return Colors.red;

      case 'Rejected':
        return Colors.redAccent;

      case 'Partially Cancelled':
        return Colors.deepOrange;

      default:
        return Colors.grey;
    }
  }

  IconData getIcon(String description) {
    switch (description) {
      case 'Total Team Members':
        return Icons.groups_rounded;

      case 'Total leaves':
        return Icons.event_note_rounded;

      case 'Average Team Leaves':
        return Icons.bar_chart_rounded;

      case 'Pending':
        return Icons.pending_actions_rounded;

      case 'Approved':
        return Icons.check_circle_rounded;

      case 'Draft':
        return Icons.edit_note_rounded;

      case 'Cancelled':
        return Icons.cancel_rounded;

      case 'Rejected':
        return Icons.highlight_off_rounded;

      case 'Partially Cancelled':
        return Icons.remove_circle_outline_rounded;

      default:
        return Icons.info_outline_rounded;
    }
  }

  String? _getDateError() {
    // Check if field is empty
    if (controller.datesController.text.isEmpty) {
      return '${AppLocalizations.of(context)!.dates} ${AppLocalizations.of(context)!.fieldRequired}';
    }

    // Check if start and end dates are set
    if (controller.startDate.value == null ||
        controller.endDate.value == null) {
      return 'Please select valid date range';
    }

    // Check if past dates are allowed
    if (!controller.isAllowedPastDates.value) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (controller.startDate.value!.isBefore(today)) {
        return 'Past dates are not allowed for this leave type';
      }

      if (controller.endDate.value!.isBefore(today)) {
        return 'Past dates are not allowed for this leave type';
      }
    }

    // Check if start date is after end date
    if (controller.startDate.value!.isAfter(controller.endDate.value!)) {
      return 'Start date cannot be after end date';
    }

    return null; // No error
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
                    '${AppLocalizations.of(context)!.submittedOn} ${DateFormat(controller.selectedFormat?.key ?? 'dd/MM/yyyy').format(item.createdDate)}',
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
                                      DateFormat(
                                        controller.selectedFormat?.key ??
                                            'dd/MM/yyyy',
                                      ).format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                          leaveDay.transDate,
                                          isUtc: true,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // In the leaveDays Obx builder, replace the items list:
                                  Expanded(
                                    child: leaveDay.noOfDays == 0
                                        ? const Text(
                                            "Non Working Day",
                                            style: TextStyle(fontSize: 12),
                                          )
                                        : Obx(() {
                                            // Build items based on AllowHalfDay from selected leave code
                                            final allowHalfDay =
                                                controller
                                                    .selectedLeaveCode
                                                    .value
                                                    ?.allowHalfDay ??
                                                true;

                                            final isPartiallyCancelled =
                                                widget
                                                    .leaveRequest
                                                    ?.leaveStatus ==
                                                "PartiallyCancelled";

                                            final dayTypeItems =
                                                (allowHalfDay &&
                                                    !isPartiallyCancelled)
                                                ? [
                                                    'Cancel Full Day',
                                                    'Cancel First Half',
                                                    'Cancel Second Half',
                                                  ]
                                                : ['Cancel Full Day'];
                                            // If current value is half day but not allowed, reset to Full Day
                                            if (!allowHalfDay &&
                                                (leaveDay.dayType.value ==
                                                        'First Half' ||
                                                    leaveDay.dayType.value ==
                                                        'Second Half')) {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                    leaveDay.dayType.value =
                                                        'Full Day';
                                                  });
                                            }

                                            return SearchableMultiColumnDropdownField<
                                              String
                                            >(
                                              readOnly: true,
                                              enabled: !leaveDay.isHoliday,
                                              labelText: AppLocalizations.of(
                                                context,
                                              )!.dayType,
                                              items:
                                                  dayTypeItems, // ← dynamic list
                                              selectedValue: leaveDay.isUserModified.value
    ? leaveDay.dayType.value
    : null,
                                              searchValue: (option) => option,
                                              displayText: (option) => option,
                                              onChanged: (option) {
                                                leaveDay.dayType.value =
                                                    option!;
                                                     leaveDay.isUserModified.value = true;  
                                                controller.modifiedDays[leaveDay
                                                        .recId!] =
                                                    option;
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
                                            );
                                          }),
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
                            // controller.resetForm();
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
                            if (_formKey.currentState!.validate() &
                                !_validateNegativeBalance()) {
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
                            if (_formKey.currentState!.validate() &
                                !_validateNegativeBalance()) {
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
                            if (_formKey.currentState!.validate() &
                                !_validateNegativeBalance()) {
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
                          if (_formKey.currentState!.validate() &
                              !_validateNegativeBalance()) {
                            controller.setButtonLoading('resubmit', true);
                            try {
                              // controller.calculateTotalDays();
                              await controller.submitLeaveRequest(
                                context,
                                true,
                                true,
                              );
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
                              if (_formKey.currentState!.validate() &
                                  !_validateNegativeBalance()) {
                                controller.setButtonLoading('update', true);
                                try {
                                  // controller.calculateTotalDays();
                                  await controller.submitLeaveRequest(
                                    context,
                                    false,
                                    false,
                                  );
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
                      if (!_formKey.currentState!.validate() &&
                          !_validateNegativeBalance()) {
                        setState(() {});
                        return;
                      }

                      controller.setButtonLoading('submit', true);

                      try {
                        // controller.calculateTotalDays();
                        await controller.submitLeaveRequest(
                          context,
                          true,
                          false,
                        );
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
                            if (!_formKey.currentState!.validate() &&
                                !_validateNegativeBalance()) {
                              setState(() {});
                              return;
                            }

                            controller.setButtonLoading('save', true);

                            try {
                              // controller.calculateTotalDays();
                              await controller.submitLeaveRequest(
                                context,
                                false,
                                false,
                              );
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
                  widget.leaveRequest!.leaveStatus == "PartiallyCancelled" &&
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
                              if (!_formKey.currentState!.validate() &&
                                  !_validateNegativeBalance() &&
                                  controller.commentsController.text.isEmpty) {
                                setState(() {});
                                return;
                              }
                              if (!isAllowPastDate.value) {
                                // Fluttertoast.showToast(
                                //   msg: "Receipt Required",
                                //   backgroundColor: const Color.fromARGB(
                                //     255,
                                //     247,
                                //     2,
                                //     2,
                                //   ),
                                //   textColor: const Color.fromARGB(
                                //     255,
                                //     253,
                                //     253,
                                //     252,
                                //   ),
                                // );
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
                                // controller.calculateTotalDays();/
                                await controller.submitLeaveRequest(
                                  context,
                                  true,
                                  false,
                                );
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

                                  if (!_formKey.currentState!.validate() &&
                                      !_validateNegativeBalance() &&
                                      controller
                                          .commentsController
                                          .text
                                          .isEmpty) {
                                    setState(() {});
                                    return;
                                  }
                                  if (!isAllowPastDate.value) {
                                    // Fluttertoast.showToast(
                                    //   msg: "Receipt Required",
                                    //   backgroundColor: const Color.fromARGB(
                                    //     255,
                                    //     247,
                                    //     2,
                                    //     2,
                                    //   ),
                                    //   textColor: const Color.fromARGB(
                                    //     255,
                                    //     253,
                                    //     253,
                                    //     252,
                                    //   ),
                                    // );
                                    return;
                                  }
                                  controller.setButtonLoading(
                                    'saveDraft',
                                    true,
                                  );

                                  try {
                                    // controller.calculateTotalDays();
                                    await controller.submitLeaveRequest(
                                      context,
                                      false,
                                      false,
                                    );
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
  // Helper method to add inside _ViewEditLeavePageState:

  bool _validateNegativeBalance() {
    final leaveCode = controller.selectedLeaveCode.value;
    if (leaveCode == null) return true;

    // ✅ Skip validation if negative balance is allowed
    if (leaveCode.allowNegativeBal) return true;

    final double requested = controller.totalRequestedDays.value.toDouble();
    final double available = leaveCode.leaveBalance;

    debugPrint(
      'Balance check → leaveCode: ${leaveCode.leaveCode}, '
      'available: $available, requested: $requested',
    );
    if (controller.commentsController.text.isEmpty) {
      return false;
    }
    if (requested > available) {
      Fluttertoast.showToast(
        msg:
            'Insufficient leave balance for "${leaveCode.leaveCode}".\n'
            'Available: $available days | Requested: $requested days.',
        backgroundColor: Colors.red[100],
        textColor: Colors.red[800],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      return false;
    }

    return true;
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
