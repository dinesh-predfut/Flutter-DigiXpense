import 'dart:convert';
import 'package:diginexa/core/comman/widgets/noDataFind.dart' show CommonNoDataWidget;
import 'package:diginexa/core/comman/widgets/pageLoaders.dart';
import 'package:diginexa/core/comman/widgets/searchDropown.dart'
    show SearchableMultiColumnDropdownField;
import 'package:diginexa/core/constant/url.dart';
import 'package:diginexa/data/models.dart';
import 'package:diginexa/data/pages/API_Service/apiService.dart';
import 'package:diginexa/data/pages/screen/widget/router/router.dart';
import 'package:diginexa/data/service.dart';
import 'package:diginexa/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;

class ExternalApprovalMetadataPage extends StatefulWidget {
  const ExternalApprovalMetadataPage({super.key});

  @override
  State<ExternalApprovalMetadataPage> createState() =>
      _ExternalApprovalMetadataPageState();
}

class _ExternalApprovalMetadataPageState
    extends State<ExternalApprovalMetadataPage> {

  bool isLoading = true;
late int workitemrecid;


  final controller = Get.find<Controller>();
  @override
  void initState() {
    super.initState();
   
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: SkeletonLoaderPage());
      }

      if (controller.metadata == null || controller.metadata!.isEmpty) {
       CommonNoDataWidget();
      }

      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildDynamicSection(controller.metadata!),
              _buildActionButtons(context),
            ],
          ),
        ),
      );
    }),
  );
}


  Widget _buildDynamicSection(Map<String, dynamic> data) {
    List<Widget> widgets = [];

    data.forEach((key, value) {
      /// Simple values
      if (value == null) return;

      if (value is String || value is num || value is bool) {
        widgets.add(_buildTextField(_formatKey(key), value.toString()));
      }
      /// Nested Map
      else if (value is Map) {
        widgets.add(_buildSectionTitle(_formatKey(key)));

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _buildDynamicSection(Map<String, dynamic>.from(value)),
          ),
        );
      }
      /// List Handling (SAFE)
      else if (value is List) {
        widgets.add(_buildSectionTitle(_formatKey(key)));

        for (var item in value) {
          if (item is Map) {
            widgets.add(
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _buildDynamicSection(Map<String, dynamic>.from(item)),
                ),
              ),
            );
          } else {
            widgets.add(_buildTextField(_formatKey(key), item.toString()));
          }
        }
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  void showActionPopup(BuildContext context, String status) {
    final TextEditingController commentController = TextEditingController();
    bool isCommentError = false;
    final loc = AppLocalizations.of(context)!;

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
                      loc.action,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (status == "Escalate") ...[
                      Text(
                        '${loc.selectUser}*',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => SearchableMultiColumnDropdownField<User>(
                          labelText: '${loc.user} *',
                          columnHeaders: [loc.userName, loc.userId],
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
                    Text('${AppLocalizations.of(context)!.comments} ${status == "Reject" ? "*" : '' }', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: loc.enterCommentHere,
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
                          child: Text(loc.close),
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

                            final success = await controller.approvalHubExternalpostApprovalAction(
                              context,
                              workitemrecid: [?workitemrecid],
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
                              Navigator.pushNamed(
                                  context, AppRoutes.approvalHubMain);
                              controller.isApprovalEnable.value = false;
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Failed to submit action')),
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

  Widget _buildTextField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        /// 🔹 First Row (Approve / Reject)
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'approve',
                AppLocalizations.of(context)!.approve,
                const Color.fromARGB(255, 30, 117, 3),
                "Approve",
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                'reject',
                AppLocalizations.of(context)!.reject,
                const Color.fromARGB(255, 238, 20, 20),
                "Reject",
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        /// 🔹 Second Row (Escalate / Skip)
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'escalate',
                AppLocalizations.of(context)!.escalate,
                const Color.fromARGB(255, 3, 20, 117),
                "Escalate",
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildSkipButton(context)),
          ],
        ),
      ],
    );
  }

  Widget _buildSkipButton(BuildContext context) {
    return Obx(() {
      final isLoadingClose = controller.buttonLoaders['close_review'] ?? false;

      final isAnyLoading = controller.buttonLoaders.values.any(
        (loading) => loading == true,
      );

      return SizedBox(
        height: 48,
        child: ElevatedButton(
          onPressed: (isLoadingClose || isAnyLoading)
              ? null
              : () async {
                  controller.setButtonLoading('close_review', true);
                  try {
                   controller.fetchApprovalDetailsExternal(controller.workitemrecid,"","");
                  } finally {
                    controller.setButtonLoading('close_review', false);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: isLoadingClose
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                )
              : Text(AppLocalizations.of(context)!.skip),
        ),
      );
    });
  }

  Widget _buildActionButton(
    BuildContext context,
    String key,
    String label,
    Color color,
    String actionType,
  ) {
    return Obx(() {
      bool isLoading = controller.buttonLoaders[key] ?? false;

      return SizedBox(
        height: 48,
        child: ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  controller.setButtonLoading(key, true);
                  try {
                    showActionPopup(context, actionType);
                  } finally {
                    controller.setButtonLoading(key, false);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(label, style: const TextStyle(color: Colors.white)),
        ),
      );
    });
  }

 

  String _formatKey(String key) {
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .replaceAll('_', ' ')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
