import 'dart:async';
import 'package:digi_xpense/core/constant/Parames/params.dart' show Params;
import 'package:digi_xpense/data/models.dart'
    show BoardTemplate, Employee, EmployeeGroup;
import 'package:digi_xpense/data/service.dart' show Controller;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:digi_xpense/l10n/app_localizations.dart';
import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';
import 'package:digi_xpense/core/comman/widgets/button.dart';
import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/core/comman/widgets/multiselectDropdown.dart';

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
  final controller = Get.put(Controller());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> _tabTitles = ['Employees', 'Employees Groups'];
  int _selectedTabIndex = 0;
  @override
  void initState() {
    super.initState();
    controller.fetchTemplates();
    loadEmployee();
    controller.fetchEmployeeGroups();
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Edit Board' : 'Create Board'),
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
                            children: List.generate(_tabTitles.length, (index) {
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
              'Visibility of your board *',
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
                    title: 'Public',
                    subtitle: 'Visible to everyone',
                    isSelected: controller.isPublic.value,
                    onTap: () => controller.isPublic.value = true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildVisibilityOption(
                    title: 'Private',
                    subtitle: 'Only selected users',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller.boardNameController,
          decoration: InputDecoration(
            labelText: 'Board Name *',
            hintText: 'Enter board name',
            border: const OutlineInputBorder(),
            errorText: controller.showBoardNameError.value
                ? 'Board name is required'
                : null,
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              controller.showBoardNameError.value = false;
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Board name is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller.descriptionController,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Enter description',
            labelText: "Description",
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
            labelText: 'Reference type',
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
            columnHeaders: const ['Type'],
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
            labelText: 'Reference',
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
                'Select Template *',
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
                      'Please select a template',
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

        if (controller.showTemplateError.value)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Template is required',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
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
            enabled: true,
            labelText: 'Select User(s)',
            items: controller.employees,
            selectedValues: controller.selectedEmployees,
            isMultiSelect: true,
            dropdownMaxHeight: 300,

            searchValue: (emp) => '${emp.id} ${emp.fullName} ',
            displayText: (emp) => emp.fullName,
            onMultiChanged: (employees) {
              controller.selectedEmployees.assignAll(employees);
            },
            columnHeaders: const ['Employee ID', 'Name', 'Department'],
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
                    // Expanded(child: Text(emp.depo ?? 'N/A')),
                  ],
                ),
              );
            },
            onChanged: (emp) {}, // Not used for multi-select
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
        // Remove Obx wrapper since there are no observable variables inside
        MultiSelectMultiColumnDropdownField<EmployeeGroup>(
          enabled: true,
          labelText: 'Select Groups',
          items: controller.employeeGroups,
          selectedValues: controller.selectedGroups,
          isMultiSelect: true,
          searchValue: (group) => '${group.name} ${group.description ?? ""}',
          displayText: (group) => group.name,
          dropdownMaxHeight: 300,
          onMultiChanged: (groups) {
            controller.selectedGroups.assignAll(groups);

            // Add group members to selected employees
            for (final group in groups) {
              for (final member in group.members) {
                if (!controller.selectedEmployees.any(
                  (e) => e.id == member.id,
                )) {
                  controller.selectedEmployees.add(member);
                }
              }
            }
          },
          columnHeaders: const ['Group Name', 'Description'],
          rowBuilder: (group, searchQuery) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      group.id,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      group.description ?? 'No description',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          onChanged: (group) {}, // Not used for multi-select
        ),

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
                  label: Text(group.name),
                  onDeleted: () {
                    controller.selectedGroups.remove(group);
                    // Remove group members from selected employees
                    for (final member in group.members) {
                      if (controller.selectedEmployees.any(
                        (e) => e.id == member.id,
                      )) {
                        // Check if member is not in any other selected group
                        bool isInOtherGroup = false;
                        for (final otherGroup in controller.selectedGroups) {
                          if (otherGroup != group &&
                              otherGroup.members.any(
                                (e) => e.id == member.id,
                              )) {
                            isInOtherGroup = true;
                            break;
                          }
                        }
                        if (!isInOtherGroup) {
                          controller.selectedEmployees.removeWhere(
                            (e) => e.id == member.id,
                          );
                        }
                      }
                    }
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
                      'Cancel',
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
                      if (_formKey.currentState!.validate()) {
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
                      'Save',
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
        title: const Text('Delete Board'),
        content: const Text(
          'Are you sure you want to delete this board? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Call delete API
              Navigator.pop(context);
              Navigator.pop(context, true); // Return success
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
