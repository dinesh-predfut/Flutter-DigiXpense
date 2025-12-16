import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:digi_xpense/l10n/app_localizations.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';
import 'package:digi_xpense/core/comman/widgets/button.dart';
import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/core/comman/widgets/multiselectDropdown.dart';

class ViewEditLeavePage extends StatefulWidget {
  final bool isReadOnly;
  final LeaveRequest? leaveRequest;
  const ViewEditLeavePage({
    Key? key,
    required this.isReadOnly,
    this.leaveRequest,
  }) : super(key: key);

  @override
  State<ViewEditLeavePage> createState() => _ViewEditLeavePageState();
}

class _ViewEditLeavePageState extends State<ViewEditLeavePage> {
  final Controller controller = Get.find<Controller>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    
    // Load existing data if editing
    if (widget.leaveRequest != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadExistingLeaveRequest(widget.leaveRequest!);
        controller.fetchProjectName();
        controller.fetchLocation();
      });
    } else {
      // Set default dates for new request
      controller.startDate.value = DateTime.now();
      controller.endDate.value = DateTime.now().add(const Duration(days: 1));
      controller.calculateTotalDays();
      controller.updateDatesController();
      controller.leaveconfiguration();

    }
  }
  
  Future<void> _selectDateRange(BuildContext context) async {
    final initialDate = controller.startDate.value ?? DateTime.now();
    
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      initialDateRange: controller.startDate.value != null && controller.endDate.value != null
          ? DateTimeRange(
              start: controller.startDate.value!,
              end: controller.endDate.value!,
            )
          : DateTimeRange(
              start: initialDate,
              end: initialDate.add(const Duration(days: 1)),
            ),
      initialEntryMode: DatePickerEntryMode.calendar,
    );
    
    if (picked != null) {
      controller.startDate.value = picked.start;
      controller.endDate.value = picked.end;
      controller.calculateTotalDays();
      controller.updateDatesController();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.leaveRequest != null
              ? AppLocalizations.of(context)!.editLeaveRequest
              : AppLocalizations.of(context)!.newLeaveRequest,
        ),
        actions: widget.isReadOnly && widget.leaveRequest?.approvalStatus != 'Approved'
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Enable edit mode logic
                  },
                ),
              ]
            : null,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status if editing
                if (widget.leaveRequest != null && widget.leaveRequest!.approvalStatus != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _getStatusColor(widget.leaveRequest!.approvalStatus!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Status: ${widget.leaveRequest!.approvalStatus}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                // Leave Code *
               SearchableMultiColumnDropdownField<LeaveCodeModel>(
                      enabled: !widget.isReadOnly,
                      labelText: '${AppLocalizations.of(context)!.leaveCode}*',
                      columnHeaders: [
                        AppLocalizations.of(context)!.code,
                        AppLocalizations.of(context)!.name,
                        AppLocalizations.of(context)!.type,
                      ],
                      items: controller.leaveCodes,
                      selectedValue: controller.selectedLeaveCode.value,
                      searchValue: (code) => '${code.code} ${code.name} ${code.type}',
                      displayText: (code) => code.name,
                      validator:  (value) {
                              if (value == null ) {
                                return '${AppLocalizations.of(context)!.leaveCode} ${AppLocalizations.of(context)!.fieldRequired}';
                              }
                              return null;
                            },
                          
                      onChanged: (code) {
                        controller.selectedLeaveCode.value = code;
                        controller.leaveCodeController.text = code?.name ?? '';
                      } ,
                      controller: controller.leaveCodeController,
                      rowBuilder: (code, searchQuery) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              Expanded(child: Text(code.code)),
                              Expanded(child: Text(code.name)),
                              Expanded(child: Text(code.type)),
                            ],
                          ),
                        );
                      },
                    ),
                 
                
                const SizedBox(height: 16),
                
                // Two column layout for Reliever and Project
                Row(
                  children: [
                    // Reliever
                    Expanded(
                      child: _buildConfigurableField(
                        fieldName: 'Delegated authority/Reliever',
                        builder: (isEnabled, isMandatory) {
                          return SearchableMultiColumnDropdownField<EmployeeModel>(
                            enabled: !widget.isReadOnly && isEnabled,
                            labelText: '${AppLocalizations.of(context)!.reliever}${isMandatory ? ' *' : ''}',
                            columnHeaders: [
                              AppLocalizations.of(context)!.employeeId,
                              AppLocalizations.of(context)!.name,
                              AppLocalizations.of(context)!.department,
                            ],
                            items: controller.employees,
                            selectedValue: controller.selectedReliever.value,
                            searchValue: (emp) => '${emp.employeeId} ${emp.name} ${emp.department}',
                            displayText: (emp) => emp.name,
                            validator: isMandatory
                                ? (value) {
                                    if (value == null ) {
                                      return '${AppLocalizations.of(context)!.reliever} ${AppLocalizations.of(context)!.fieldRequired}';
                                    }
                                    return null;
                                  }
                                : null,
                            onChanged: (emp) {
                              controller.selectedReliever.value = emp;
                              controller.relieverController.text = emp?.name ?? '';
                            } ,
                            controller: controller.relieverController,
                            rowBuilder: (emp, searchQuery) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(emp.employeeId)),
                                    Expanded(child: Text(emp.name)),
                                    Expanded(child: Text(emp.department)),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Project
                    Expanded(
                      child: _buildConfigurableField(
                        fieldName: AppLocalizations.of(context)!.projectId,
                        builder: (isEnabled, isMandatory) {
                          return SearchableMultiColumnDropdownField<Project>(
                            labelText:
                                '${AppLocalizations.of(context)!.projectId} ${isMandatory ? "*" : ""}',
                            columnHeaders: const ['Project Name', 'Project Id'],
                            items: controller.project,
                            selectedValue: controller.selectedProject,
                            searchValue: (proj) => '${proj.name} ${proj.code}',
                            displayText: (proj) => proj.code,
                            onChanged: (proj) {
                              setState(() {
                                controller.selectedProject = proj;
                                controller.selectedProject = proj;
                                // Clear validation error when a project is selected
                                if (proj != null) {
                                  controller.showProjectError.value = false;
                                }
                              });
                              controller.fetchExpenseCategory();
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
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Dates * (Always required)
                TextFormField(
                  controller: controller.datesController,
                  readOnly: true,
                  enabled: !widget.isReadOnly,
                  decoration: InputDecoration(
                    labelText: '${AppLocalizations.of(context)!.dates} *',
                    border: const OutlineInputBorder(),
                    suffixIcon: !widget.isReadOnly
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
                ),
                
                const SizedBox(height: 16),
                
                // Divider line
                Divider(
                  color: Colors.grey[300],
                  thickness: 1,
                  height: 20,
                ),
                
                // Location
                _buildConfigurableField(
                  fieldName: 'Location during leave',
                  builder: (isEnabled, isMandatory) {
                    return SearchableMultiColumnDropdownField<
                                  LocationModel>(
                                labelText:
                                    '${AppLocalizations.of(context)!.location} ${isMandatory ? "*" : ""}',
                                items: controller.location,
                                selectedValue: controller.selectedLocation,
                                // enabled: controller.isEditModePerdiem,
                                controller: controller.locationController,
                                searchValue: (proj) => proj.location,
                                displayText: (proj) => proj.location,
                                validator: (proj) =>
                                    isMandatory && proj == null
                                        ? AppLocalizations.of(context)!.selectLocale
                                        : null,
                                onChanged: (proj) {
                                  controller.selectedLocation = proj;
                                  controller.fetchPerDiemRates();
                                 
                                 
                                },
                                columnHeaders: [
                                  AppLocalizations.of(context)!.location,
                                  AppLocalizations.of(context)!.country
                                ],
                                rowBuilder: (proj, searchQuery) {
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
                              );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Notifying Users
                _buildConfigurableField(
                  fieldName: 'Notifying users',
                  builder: (isEnabled, isMandatory) {
                    return MultiSelectMultiColumnDropdownField<EmployeeModel>(
                      enabled: !widget.isReadOnly && isEnabled,
                      labelText: '${AppLocalizations.of(context)!.notifyingUsers}${isMandatory ? ' *' : ''}',
                      items: controller.notifyingUsers,
                      selectedValues: controller.selectedNotifyingUsers,
                      isMultiSelect: true,
                      searchValue: (user) => '${user.employeeId} ${user.name}',
                      displayText: (user) => user.name,
                      validator: isMandatory
                          ? (value) {
                              if (controller.selectedNotifyingUsers.isEmpty) {
                                return '${AppLocalizations.of(context)!.notifyingUsers} ${AppLocalizations.of(context)!.fieldRequired}';
                              }
                              return null;
                            }
                          : null,
                      onMultiChanged: (users) {
                        controller.selectedNotifyingUsers.assignAll(users);
                      } ,
                      columnHeaders: [
                        AppLocalizations.of(context)!.employeeId,
                        AppLocalizations.of(context)!.name,
                        AppLocalizations.of(context)!.mail,
                      ],
                      rowBuilder: (user, searchQuery) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              Expanded(child: Text(user.employeeId)),
                              Expanded(child: Text(user.name)),
                              Expanded(child: Text(user.email)),
                            ],
                          ),
                        );
                      }, onChanged: (EmployeeModel? p1) {  },
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Contact number
                _buildConfigurableField(
                  fieldName: 'Contact number',
                  builder: (isEnabled, isMandatory) {
                    return TextFormField(
                      controller: controller.contactNumberController,
                      enabled: !widget.isReadOnly && isEnabled,
                      decoration: InputDecoration(
                        labelText: '${AppLocalizations.of(context)!.contactNumber}${isMandatory ? ' *' : ''}',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: isMandatory
                          ? (value) {
                              if (value == null || value.isEmpty) {
                                return '${AppLocalizations.of(context)!.contactNumber} ${AppLocalizations.of(context)!.fieldRequired}';
                              }
                              return null;
                            }
                          : null,
                      onChanged: !widget.isReadOnly && isEnabled
                          ? (value) => controller.contactNumber.value = value
                          : null,
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Divider line
                Divider(
                  color: Colors.grey[300],
                  thickness: 1,
                  height: 20,
                ),
                
                // Comments *
                TextFormField(
                  controller: controller.commentsController,
                  enabled: !widget.isReadOnly,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: '${AppLocalizations.of(context)!.comments} *',
                    border: const OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '${AppLocalizations.of(context)!.comments} ${AppLocalizations.of(context)!.fieldRequired}';
                    }
                    return null;
                  },
                  onChanged: !widget.isReadOnly
                      ? (value) => controller.comments.value = value
                      : null,
                ),
                
                const SizedBox(height: 16),
                
                // Availability During Leave
                _buildConfigurableField(
                  fieldName: 'Availability during leave',
                  builder: (isEnabled, isMandatory) {
                    return SearchableMultiColumnDropdownField<String>(
                      enabled: !widget.isReadOnly && isEnabled,
                      labelText: '${AppLocalizations.of(context)!.availabilityDuringLeave}${isMandatory ? ' *' : ''}',
                      columnHeaders: [
                        AppLocalizations.of(context)!.availability,
                      ],
                      items: controller.availabilityOptions,
                      selectedValue: controller.selectedAvailability.value,
                      searchValue: (option) => option,
                      displayText: (option) => option,
                      validator: isMandatory
                          ? (value) {
                              if (value == null || value.isEmpty) {
                                return '${AppLocalizations.of(context)!.availabilityDuringLeave} ${AppLocalizations.of(context)!.fieldRequired}';
                              }
                              return null;
                            }
                          : null,
                      onChanged: (option) {
                        controller.selectedAvailability.value = option ?? '';
                        controller.availabilityController.text = option ?? '';
                      } ,
                      controller: controller.availabilityController,
                      rowBuilder: (option, searchQuery) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              Expanded(child: Text(option)),
                            ],
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
                      controller: controller.outOfOfficeMessageController,
                      enabled: !widget.isReadOnly && isEnabled,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: '${AppLocalizations.of(context)!.outOfOfficeMessage}${isMandatory ? ' *' : ''}',
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
                      onChanged: !widget.isReadOnly && isEnabled
                          ? (value) => controller.outOfOfficeMessage.value = value
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
                      title: Text(AppLocalizations.of(context)!.notifyHR),
                      value: controller.notifyHR.value,
                      onChanged: !widget.isReadOnly && isEnabled
                          ? (value) => controller.notifyHR.value = value ?? false
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
                      title: Text(AppLocalizations.of(context)!.notifyTeamMembers),
                      value: controller.notifyTeam.value,
                      onChanged: !widget.isReadOnly && isEnabled
                          ? (value) => controller.notifyTeam.value = value ?? false
                          : null,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                ),
                
                // Paid/Unpaid Leave Flag
                _buildConfigurableField(
                  fieldName: 'Paid/Unpaid Leave flag',
                  builder: (isEnabled, isMandatory) {
                    if (!isEnabled) return const SizedBox.shrink();
                    
                    return SwitchListTile(
                      title: Text(AppLocalizations.of(context)!.paidLeave),
                      value: controller.isPaidLeave.value,
                      onChanged: !widget.isReadOnly && isEnabled
                          ? (value) => controller.isPaidLeave.value = value
                          : null,
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Total Days Display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.totalDays,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Text(
                        '${controller.totalDays.value} ${AppLocalizations.of(context)!.days}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      )),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Action Buttons
                if (!widget.isReadOnly) _buildActionButtons(),
                if (widget.isReadOnly) _buildViewModeButtons(),
              ],
            ),
          ),
        );
      }),
    );
  }
  
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Submit Button
        Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isButtonLoading('submit')
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      controller.submitLeaveRequest(context, false);
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
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
                    ),
                  ),
          ),
        )),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            // Save as Draft Button
            Expanded(
              child: Obx(() => ElevatedButton(
                onPressed: controller.isButtonLoading('saveDraft')
                    ? null
                    : () {
                        controller.submitLeaveRequest(context, true);
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
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
                        AppLocalizations.of(context)!.saveAsDraft,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              )),
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
    );
  }
  
  Widget _buildViewModeButtons() {
    return Column(
      children: [
        if (widget.leaveRequest?.approvalStatus == 'Rejected' ||
            widget.leaveRequest?.approvalStatus == 'Draft')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Enable edit mode
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
              ),
              child: Text(
                AppLocalizations.of(context)!.edit,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        
        const SizedBox(height: 12),
        
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.grey,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text(
            AppLocalizations.of(context)!.close,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
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
}

// Add to your main.dart or wherever you initialize GetX
void initializeControllers() {
  Get.put(Controller());
}