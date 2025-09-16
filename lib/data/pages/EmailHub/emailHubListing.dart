import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../core/comman/widgets/pageLoaders.dart';
import '../../../l10n/app_localizations.dart';
import 'emailDetailsPage.dart';

class EmailHubScreen extends StatefulWidget {
  const EmailHubScreen({Key? key}) : super(key: key);

  @override
  State<EmailHubScreen> createState() => _EmailHubScreenState();
}

class _EmailHubScreenState extends State<EmailHubScreen> {
  final TextEditingController _searchController = TextEditingController();
  final controllers = Get.put(Controller());
  List<EmailHubModel> _emails = [];
  List<EmailHubModel> _filteredEmails = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  EmailHubModel? _selectedEmail;

  final List<String> _filterOptions = [
    'All',
    'Processed',
    'Un-Processed',
    'Rejected'
  ];

  @override
  void initState() {
    super.initState();
    _loadEmails();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controllers.getPersonalDetails(context);
      if (controllers.profileImage.value == null) {
        controllers.getProfilePicture();
      }
    });

    _searchController.addListener(() {
      _searchEmails(_searchController.text);
    });
  }

  Future<void> _loadEmails() async {
    try {
      setState(() => _isLoading = true);
      final response = await controllers.getEmailHubList();
      final List<dynamic> emailList = response['emails'];

      final emails = <EmailHubModel>[];
      for (var item in emailList) {
        if (item is Map<String, dynamic>) {
          emails.add(EmailHubModel.fromJson(item));
        } else if (item is EmailHubModel) {
          // Already an instance
          emails.add(item);
        }
      }

      setState(() {
        _emails = emails;
        _applyFilters(); // Apply current filter after load
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error loading emails: $e');
      print(stackTrace);
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading emails: $e')),
      );
    }
  }

  // Convert backend status to display label
  String getDisplayStatus(String status) {
    switch (status) {
      case 'SuccessfullyProcessed':
        return 'Processed';
      case 'InProgress':
      case 'Unprocessed':
        return 'Un-Processed';
      case 'Rejected':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  // Map display label back to actual statuses
  bool _matchesFilter(EmailHubModel email, String filter) {
    final status = email.emailStatus;

    switch (filter) {
      case 'All':
        return true;
      case 'Processed':
        return status == 'SuccessfullyProcessed';
      case 'Un-Processed':
        return status == 'Unprocessed' || status == 'InProgress';
      case 'Rejected':
        return status == 'Rejected';
      default:
        return false;
    }
  }

  // Apply both filter and search
  void _applyFilters() {
    List<EmailHubModel> result = _emails;

    // Apply filter
    if (_selectedFilter != 'All') {
      result = result
          .where((email) => _matchesFilter(email, _selectedFilter))
          .toList();
    }

    // Apply search (if any)
    final query = _searchController.text;
    if (query.isNotEmpty) {
      result = result.where((email) {
        final q = query.toLowerCase();
        return email.subject.toLowerCase().contains(q) ||
            email.name.toLowerCase().contains(q);
      }).toList();
    }

    setState(() {
      _filteredEmails = result;
    });
  }

  void _filterEmails(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _applyFilters(); // Re-apply both filter and search
  }

  void _searchEmails(String query) {
    _applyFilters(); // Re-apply filters with search term
  }

  Color _getStatusColor(String status) {
    final displayStatus = getDisplayStatus(status).toLowerCase();
    switch (displayStatus) {
      case 'processed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'un-processed':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showEmailPreview(EmailHubModel email) {
    setState(() {
      _selectedEmail = email;
    });
  }

  Future<String?> _showRejectDialog() async {
    final TextEditingController reasonController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title:  Text(AppLocalizations.of(context)!.rejectEmail),
        content: TextField(
          controller: reasonController,
          decoration:  InputDecoration(
            labelText: AppLocalizations.of(context)!.reasonForRejection,
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:  Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, reasonController.text),
            child:  Text(AppLocalizations.of(context)!.reject),
          ),
        ],
      ),
    );
  }

  void _rejectEmail(String emailId) async {
    final reason = await _showRejectDialog();
    if (reason != null) {
      try {
        await controllers.rejectEmails(emailId, reason);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email rejected successfully')),
        );
        _loadEmails(); // Refresh list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting email: $e')),
        );
      }
    }
  }

  // Helper: Get color for avatar based on initials
  Color getColorForInitials(String initials) {
    final colors = [
      Colors.orange,
      Colors.purple,
      Colors.green,
      Colors.red,
      Colors.blue,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    int sum = 0;
    for (int i = 0; i < initials.length; i++) {
      sum += initials.codeUnitAt(i);
    }
    return colors[sum % colors.length];
  }

  @override
  Widget build(BuildContext context) {
     final theme = Theme.of(context);
    return Scaffold(
      // backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title:  Text(
         AppLocalizations.of(context)!.emailHub,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        // backgroundColor: const Color(0xFF1E215C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_selectedEmail != null)
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {
                // Share logic
              },
            ),
        ],
      ),
      body: Row(
        children: [
          // Email List Panel (30%)
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:AppLocalizations.of(context)!.search,
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          // Navigate to personal info (or profile screen)
                          // Navigator.pushNamed(context, AppRoutes.personalInfo);
                          // For now, just print
                          print("Profile tapped");
                        },
                        child: Obx(() {
                          final controller = Get.find<
                              Controller>(); // Ensure your controller is Get.find-able
                          return Container(
                            width: 44,
                            height: 44,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: controller.isImageLoading.value
                                  ? const SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: CircularProgressIndicator(
                                        color: Colors.grey,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : controller.profileImage.value != null
                                      ? Image.file(
                                          controller.profileImage.value!,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                            ),
                          );
                        }),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),

                // Filter Tabs (Underline Style)
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: _filterOptions.map((filter) {
                      final isSelected = _selectedFilter == filter;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _filterEmails(filter),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.fastOutSlowIn,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF1E215C)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 8),
                            child: Column(
                              children: [
                                // Text with smooth color animation
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    letterSpacing: isSelected ? 0.3 : 0,
                                  ),
                                  child: Text(
                                    filter,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),

                                const SizedBox(height: 6),

                                // Smooth growing rounded underline
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  width: isSelected ? 50 : 0,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color:
                                                  Colors.white.withOpacity(0.6),
                                              blurRadius: 6,
                                              spreadRadius: 1,
                                            )
                                          ]
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),

                // Email List
                Expanded(
                  child: _isLoading
                      ? const Center(child: SkeletonLoaderPage())
                      : _filteredEmails.isEmpty
                          ?  Center(
                              child: Text(
                               AppLocalizations.of(context)!.noEmailsFound,
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadEmails,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                itemCount: _filteredEmails.length,
                                itemBuilder: (context, index) {
                                  final email = _filteredEmails[index];
                                  final isSelected =
                                      _selectedEmail?.recId == email.recId;

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                      leading: CircleAvatar(
                                        radius: 20,
                                        backgroundColor:
                                            getColorForInitials(email.name),
                                        child: Text(
                                          (email.name.isNotEmpty
                                                  ? email.name.trim()[0]
                                                  : '?')
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        email.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            email.subject,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            getDisplayStatus(email.emailStatus),
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: ElevatedButton(
                                        onPressed: email.emailStatus ==
                                                'Rejected'
                                            ? null
                                            : () {
                                                if (email.emailStatus ==
                                                    'SuccessfullyProcessed') {
                                                  // Already processed
                                                } else {
                                                  _rejectEmail(
                                                      email.recId.toString());
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: _getStatusColor(
                                              email.emailStatus),
                                          shadowColor:
                                              Colors.black.withOpacity(0.3),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 0),
                                        ),
                                        child: Text(
                                          getDisplayStatus(email.emailStatus),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _selectedEmail = email;
                                        });
                                        // Navigate to detail page
                                        controllers.fetchEmailDetails(
                                            email.recId, context);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),

          // Email Preview Panel (70%) - Optional: Add later
          // Expanded(flex: 7, child: _buildPreview())
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
