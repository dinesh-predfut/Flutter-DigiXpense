import 'dart:async';
import 'package:diginexa/core/constant/Parames/params.dart' show Params;
import 'package:diginexa/data/models.dart'
    show BoardTemplate, Employee, EmployeeGroup;
import 'package:diginexa/data/pages/screen/widget/router/router.dart';
import 'package:diginexa/data/service.dart' show Controller;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:diginexa/l10n/app_localizations.dart';
import 'package:diginexa/core/comman/widgets/searchDropown.dart';
import 'package:diginexa/core/comman/widgets/button.dart';
import 'package:diginexa/core/comman/widgets/pageLoaders.dart';
import 'package:diginexa/core/comman/widgets/multiselectDropdown.dart';

// Model for Template

// Main Page Widget
class CreateEditBoardPage extends StatefulWidget {
  final bool isEditMode;
  final Map<String, dynamic>? existingBoard;

  const CreateEditBoardPage({
    super.key,
    this.isEditMode = false,
    this.existingBoard,
  });

  @override
  State<CreateEditBoardPage> createState() => _CreateEditBoardPageState();
}

class _CreateEditBoardPageState extends State<CreateEditBoardPage> {
  final controller = Get.find<Controller>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final List<String> _tabTitles = [
    AppLocalizations.of(context)!.employees,
    AppLocalizations.of(context)!.employeeGroups,
  ];
  int _selectedTabIndex = 0;
  @override
  void initState() {
    super.initState();
    loadEmployee();
    controller.fetchEmployeeGroups();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTemplates();
    });
    if (widget.isEditMode && widget.existingBoard != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadExistingBoard(widget.existingBoard!);
      });
    }
  }

  Future<void> loadEmployee() async {
    final result = await controller.fetchEmployees();
    print("resultEmployee$result");
    controller.employees.assignAll(result);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // if (!controller.isEnable.value) {
        //   controller.resetFormBoard();
        //   return true;
        // }

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
          controller.resetFormBoard();
          controller.isEnable.value = false;
          controller.isLoadingviewImage.value = false;

          Navigator.pushNamed(context, AppRoutes.boardDashboard);
          return true;
        }

        return false;
      },
      child: Scaffold(
        // backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            widget.isEditMode
                ? '${AppLocalizations.of(context)!.edit} ${AppLocalizations.of(context)!.board}'
                : AppLocalizations.of(context)!.createBoard,
          ),
          actions: [
            if (widget.isEditMode)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmation(context),
              ),
          ],
        ),
        body: Obx(() {
          final theme = Theme.of(context);
          final primaryColor = theme.primaryColor;
          return controller.isLoading.value
              ? const Center(child: SkeletonLoaderPage())
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Visibility Toggle
                        _buildVisibilityToggle(),

                        const SizedBox(height: 20),

                        // Board Name *
                        _buildBoardNameField(),

                        const SizedBox(height: 16),

                        // Description
                        _buildDescriptionField(),

                        const SizedBox(height: 16),

                        // Reference Type
                        _buildReferenceTypeField(),

                        const SizedBox(height: 16),

                        // Reference ID
                        // if (controller.selectedReferenceType.value.isNotEmpty)
                        _buildReferenceIdField(),

                        const SizedBox(height: 20),

                        // Board Template *
                        _buildTemplateField(),

                        // const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: List.generate(_tabTitles.length, (
                                index,
                              ) {
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedTabIndex = index;
                                        // if(index == 1){
                                        //   controller.selectedEmployees.clear();
                                        // }
                                        // else{
                                        //  controller.selectedGroups.clear();
                                        // }
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _selectedTabIndex == index
                                            ? theme.primaryColor
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: _selectedTabIndex == index
                                            ? [
                                                BoxShadow(
                                                  color: theme.primaryColor
                                                      .withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      margin: const EdgeInsets.all(4),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Center(
                                        child: Text(
                                          _tabTitles[index],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _selectedTabIndex == index
                                                ? Colors.white
                                                : Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        if (_selectedTabIndex == 0) _buildEmployeeSelection(),
                        if (_selectedTabIndex == 0) const SizedBox(height: 20),

                        // Employee Groups Selection
                        if (_selectedTabIndex == 1)
                          _buildEmployeeGroupSelection(),

                        const SizedBox(height: 32),

                        // Action Buttons
                        _buildActionButtons(),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
        }),
      ),
    );
  }

  Widget _buildVisibilityToggle() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.of(context)!.visibilityOfYourBoard} *',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildVisibilityOption(
                    title: AppLocalizations.of(context)!.public,
                    subtitle: AppLocalizations.of(context)!.visibleToEveryone,
                    isSelected: controller.isPublic.value,
                    onTap: () => controller.isPublic.value = true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildVisibilityOption(
                    title: AppLocalizations.of(context)!.private,
                    subtitle: AppLocalizations.of(context)!.onlySelectedUsers,
                    isSelected: !controller.isPublic.value,
                    onTap: () => controller.isPublic.value = false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardNameField() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller.boardNameController,
            inputFormatters: [
              TextInputFormatter.withFunction((oldValue, newValue) {
                // ❌ Block leading space
                if (newValue.text.startsWith(' ')) {
                  return oldValue;
                }
                return newValue;
              }),
            ],
            decoration: InputDecoration(
              labelText: '${AppLocalizations.of(context)!.boardName} *',
              hintText: AppLocalizations.of(context)!.enterBoardName,
              border: const OutlineInputBorder(),
              errorText: controller.showBoardNameError.value
                  ? controller.boardNameErrorMsg.value
                  : null,
            ),
            onChanged: (value) {
              // Remove leading spaces automatically
              if (value.startsWith(' ')) {
                controller.boardNameController.text = value.trimLeft();
                controller.boardNameController.selection =
                    TextSelection.fromPosition(
                      TextPosition(
                        offset: controller.boardNameController.text.length,
                      ),
                    );
              }

              if (value.trim().isNotEmpty) {
                controller.showBoardNameError.value = false;
              }
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                controller.showBoardNameError.value = true;
                return AppLocalizations.of(context)!.boardNameIsRequired;
              }

              // ❌ Leading space
              if (value.startsWith(' ')) {
                return "Board name should not start with space";
              }

              // ❌ Trailing space
              if (value.endsWith(' ')) {
                return "Board name should not end with space";
              }

              // ❌ Only spaces between (like "   ")
              if (!RegExp(r'[a-zA-Z0-9]').hasMatch(value)) {
                return "Enter valid board name";
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller.descriptionController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.description,
            labelText: AppLocalizations.of(context)!.description,
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          return SearchableMultiColumnDropdownField<String>(
            labelText: AppLocalizations.of(context)!.referenceName,
            items: controller.referenceTypes,
            selectedValue: controller.selectedReferenceType.value,
            searchValue: (type) => type,
            displayText: (type) => type,
            onChanged: (type) {
              controller.selectedReferenceType.value = type ?? '';
              controller.fetchReferenceList();
              controller.selectedReference.value = null;
            },
            rowBuilder: (type, searchQuery) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Text(type),
              );
            },
            columnHeaders: [AppLocalizations.of(context)!.type],
          );
        }),
      ],
    );
  }

  Widget _buildReferenceIdField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Obx(() {
          return SearchableMultiColumnDropdownField<Map<String, dynamic>>(
            labelText: AppLocalizations.of(context)!.referenceId,
            items: controller.referenceList,
            enabled: !controller.isLoadingReference.value,
            selectedValue: controller.selectedReference.value,
            columnHeaders: controller.referenceHeaders,
            controller: controller.referenceIdController,
            searchValue: controller.getSearchValue,
            displayText: controller.getSearchValue,
            onChanged: (value) {
              controller.selectedReference.value = value;
              if (value != null) {
                controller.setReferenceId(value);
              }
            },
            rowBuilder: (item, searchQuery) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: buildRow(item),
              );
            },
          );
        }),
      ],
    );
  }

  Widget buildRow(Map<String, dynamic> item) {
    switch (controller.selectedReferenceType.value) {
      case 'Expense':
        return Row(
          children: [
            Expanded(child: Text(item['ExpenseId'].toString())),
            Expanded(child: Text(item['ExpenseType'] ?? '')),
          ],
        );

      case 'Project':
        return Row(
          children: [
            Expanded(child: Text(item['ProjectId'].toString())),
            Expanded(child: Text(item['ProjectName'] ?? '')),
          ],
        );

      case 'Travel':
        return Row(
          children: [
            Expanded(child: Text(item['RequisitionId'].toString())),
            Expanded(child: Text(item['RequestedBy'] ?? '')),
          ],
        );

      case 'Cash Advance':
        return Row(
          children: [
            Expanded(child: Text(item['RequisitionId'].toString())),
            Expanded(child: Text(item['ApprovalStatus'] ?? '')),
          ],
        );

      case 'Payment Proposal':
        return Row(
          children: [
            Expanded(child: Text(item['ProposalId'].toString())),
            Expanded(child: Text(item['ProposalStatus'] ?? '')),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  Widget _buildTemplateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          if (controller.isLoadingTemplates.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppLocalizations.of(context)!.selectTemplate} *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1, // Adjust for better aspect ratio
                children: controller.templates.asMap().entries.map((entry) {
                  final index = entry.key;
                  final template = entry.value;
                  final color = controller
                      .templateColors[index % controller.templateColors.length];
                  print("template$template");
                  return _buildTemplateGridItem(
                    template,
                    index,
                    color,
                    controller,
                    context,
                  );
                }).toList(),
              ),

              const SizedBox(height: 8),

              // Error message
              Obx(() {
                if (controller.showTemplateError.value) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      AppLocalizations.of(context)!.pleaseSelectATemplate,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          );
        }),

        // if (controller.showTemplateError.value)
        //   Padding(
        //     padding: const EdgeInsets.only(top: 4),
        //     child: Text(
        //       AppLocalizations.of(context)!.templateIsRequired,
        //       style: TextStyle(
        //         color: Theme.of(context).colorScheme.error,
        //         fontSize: 12,
        //       ),
        //     ),
        //   ),
      ],
    );
  }

  Widget _buildTemplateGridItem(
    BoardTemplate template,
    int index,
    Color color,
    Controller controller,
    BuildContext context,
  ) {
    final isSelected =
        controller.selectedTemplate.value?.areaName == template.areaName;

    return GestureDetector(
      onTap: () {
        controller.selectedTemplate.value = template;
        controller.selectedTemplateId.value = template.areaId ?? '';
        controller.showTemplateError.value = false;
      },
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  width: 2,
                  color: Theme.of(context).colorScheme.primary,
                )
              : Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        // padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  controller.templateIcons[template.areaName] ?? Icons.category,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Template name
            Text(
              template.areaName,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Custom board indicator
            // if (template.areaName == 'Custom Board')
            //   Container(
            //     margin: const EdgeInsets.only(top: 4),
            //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            //     decoration: BoxDecoration(
            //       color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            //       borderRadius: BorderRadius.circular(4),
            //     ),
            //     child: Text(
            //       'Custom',
            //       style: TextStyle(
            //         fontSize: 10,
            //         fontWeight: FontWeight.w500,
            //         color: Theme.of(context).colorScheme.primary,
            //       ),
            //     ),
            //   ),

            // Selected indicator
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          if (controller.isLoadingEmployees.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return MultiSelectMultiColumnDropdownField<Employee>(
            key: ValueKey(controller.employeeDropdownRefresh.value),

            enabled: true,
            labelText: AppLocalizations.of(context)!.selectUsers,
            items: controller.employees,
            selectedValues: controller.selectedEmployees,
            isMultiSelect: true,
            dropdownMaxHeight: 300,

            searchValue: (emp) => '${emp.id} ${emp.fullName}',
            displayText: (emp) => emp.fullName,

            onMultiChanged: (employees) {
              controller.selectedEmployees.assignAll(employees);
            },

            columnHeaders: [
              AppLocalizations.of(context)!.employeeId,
              AppLocalizations.of(context)!.employeeName,
              AppLocalizations.of(context)!.department,
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
                    Expanded(child: Text(emp.fullName)),
                  ],
                ),
              );
            },

            onChanged: (_) {},
          );
        }),

        // Show selected employees
        Obx(() {
          if (controller.selectedEmployees.isEmpty) {
            return const SizedBox();
          }

          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.selectedEmployees.map((emp) {
                return Chip(
                  label: Text(
                    emp.fullName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  backgroundColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),

                  deleteIcon: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade300,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.black54,
                    ),
                  ),

                  deleteIconColor: Colors.black54,

                  onDeleted: () {
                    controller.selectedEmployees.remove(emp);
                    controller.employeeDropdownRefresh.value++;
                  },
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmployeeGroupSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Obx(() {
          return MultiSelectMultiColumnDropdownField<EmployeeGroup>(
            key: ValueKey(controller.groupDropdownRefresh.value),

            enabled: true,
            labelText: AppLocalizations.of(context)!.selectGroups,
            items: controller.employeeGroups,
            selectedValues: controller.selectedGroups,
            isMultiSelect: true,
            dropdownMaxHeight: 300,

            searchValue: (group) => '${group.name} ${group.description ?? ""}',

            displayText: (group) => group.id,

            onMultiChanged: (groups) {
              controller.selectedGroups.assignAll(groups);

              /// Add members automatically
              for (final group in groups) {
                for (final member in group.members) {
                  if (!controller.selectedEmployees.any(
                    (e) => e.id == member.id,
                  )) {
                    controller.selectedEmployees.add(member);
                  }
                }
              }

              /// ✅ refresh dropdown
              controller.groupDropdownRefresh.value++;
            },

            columnHeaders: [
              AppLocalizations.of(context)!.group,
              AppLocalizations.of(context)!.description,
            ],

            rowBuilder: (group, searchQuery) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(group.id)),
                    Expanded(
                      child: Text(group.description ?? 'No description'),
                    ),
                  ],
                ),
              );
            },

            onChanged: (_) {},
          );
        }),

        // Show selected groups
        Obx(() {
          if (controller.selectedGroups.isEmpty) {
            return const SizedBox();
          }

          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.selectedGroups.map((group) {
                return Chip(
                  label: Text(group.id),
                  onDeleted: () {
                    controller.selectedGroups.remove(group);

                    /// Remove group members safely
                    for (final member in group.members) {
                      bool existsInOtherGroup = controller.selectedGroups.any(
                        (g) => g.members.any((e) => e.id == member.id),
                      );

                      if (!existsInOtherGroup) {
                        controller.selectedEmployees.removeWhere(
                          (e) => e.id == member.id,
                        );
                      }
                    }

                    /// ✅ instant dropdown sync
                    controller.groupDropdownRefresh.value++;
                  },
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Save Button
        Expanded(
          child: Obx(() {
            final isLoading = controller.isButtonLoading('save');
            return ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      controller.resetFormBoard();
                      Navigator.of(context).pop(true);
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blueGrey,
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
                      AppLocalizations.of(context)!.cancel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            );
          }),
        ),

        const SizedBox(width: 12),

        // Submit/Create Button
        Expanded(
          child: Obx(() {
            final isLoading = controller.isButtonLoading('submit');
            return ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      if (controller.validateBoardForm()) {
                        controller.submitForm(context);
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
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
                      AppLocalizations.of(context)!.save,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            );
          }),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteBoard),
        content: Text(AppLocalizations.of(context)!.areYouSureDeleteBoard),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              // Call delete API
              Navigator.pop(context);
              Navigator.pop(context, true); // Return success
            },
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// Usage example in your app:
// Navigate to create board:
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => const CreateEditBoardPage(),
//   ),
// );

// Navigate to edit board:
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => CreateEditBoardPage(
//       isEditMode: true,
//       existingBoard: boardData,
//     ),
//   ),
// );
