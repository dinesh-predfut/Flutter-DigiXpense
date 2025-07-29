import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digi_xpense/core/services/new_screens_api_service.dart';
import 'package:digi_xpense/core/models/new_screens_models.dart';
import 'package:digi_xpense/core/constant/Parames/params.dart';
import 'package:intl/intl.dart';

class EmailHubScreen extends StatefulWidget {
  const EmailHubScreen({Key? key}) : super(key: key);

  @override
  State<EmailHubScreen> createState() => _EmailHubScreenState();
}

class _EmailHubScreenState extends State<EmailHubScreen> {
  final NewScreensApiService _apiService = NewScreensApiService();
  final TextEditingController _searchController = TextEditingController();
  
  List<EmailHubModel> _emails = [];
  List<EmailHubModel> _filteredEmails = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  EmailHubModel? _selectedEmail;
  
  final List<String> _filterOptions = ['All', 'Processed', 'Un-Processed', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _loadEmails();
  }

  Future<void> _loadEmails() async {
    try {
      setState(() => _isLoading = true);
      final emails = await _apiService.getEmailHubList();
      setState(() {
        _emails = emails;
        _filteredEmails = emails;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading emails: $e')),
      );
    }
  }

  void _filterEmails(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'All') {
        _filteredEmails = _emails;
      } else {
        _filteredEmails = _emails.where((email) => email.status == filter).toList();
      }
    });
  }

  void _searchEmails(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredEmails = _emails;
      } else {
        _filteredEmails = _emails.where((email) =>
          email.subject.toLowerCase().contains(query.toLowerCase()) ||
          email.senderName.toLowerCase().contains(query.toLowerCase()) ||
          email.from.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    });
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processed':
        return '#4CAF50';
      case 'rejected':
        return '#F44336';
      case 'un-processed':
        return '#FF9800';
      default:
        return '#9E9E9E';
    }
  }

  void _showEmailPreview(EmailHubModel email) {
    setState(() {
      _selectedEmail = email;
    });
  }

  void _processEmail(String emailId) async {
    try {
      await _apiService.processEmail(emailId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email processed successfully')),
      );
      _loadEmails(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing email: $e')),
      );
    }
  }

  void _rejectEmail(String emailId) async {
    final reason = await _showRejectDialog();
    if (reason != null) {
      try {
        await _apiService.rejectEmail(emailId, reason);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email rejected successfully')),
        );
        _loadEmails(); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting email: $e')),
        );
      }
    }
  }

  Future<String?> _showRejectDialog() async {
    final TextEditingController reasonController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Email'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, reasonController.text),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Email Hub',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6A4C93),
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
                // Share email functionality
              },
            ),
        ],
      ),
      body: Row(
        children: [
          // Email list section
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchEmails,
                    decoration: InputDecoration(
                      hintText: 'Search in Email',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person, size: 20),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                
                // Filter tabs
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _filterOptions.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: ElevatedButton(
                            onPressed: () => _filterEmails(filter),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected ? Colors.black : Colors.white,
                              foregroundColor: isSelected ? Colors.white : Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Email list
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredEmails.isEmpty
                          ? const Center(
                              child: Text(
                                'No emails found',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadEmails,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _filteredEmails.length,
                                itemBuilder: (context, index) {
                                  final email = _filteredEmails[index];
                                  final isSelected = _selectedEmail?.emailId == email.emailId;
                                  
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.blue[50] : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: isSelected 
                                          ? Border.all(color: Colors.blue, width: 2)
                                          : null,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(12),
                                      leading: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.grey[200],
                                        child: Text(
                                          email.senderInitials,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        email.senderName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                            email.timestamp,
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(int.parse(
                                            _getStatusColor(email.status).replaceAll('#', '0xFF'),
                                          )),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          email.status,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      onTap: () => _showEmailPreview(email),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
          
          // Email preview section
          if (_selectedEmail != null)
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Email header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Preview',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () {
                                  // Share functionality
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'From: ${_selectedEmail!.from}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            'To: ${_selectedEmail!.to}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Subject: ${_selectedEmail!.subject}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Date: ${_selectedEmail!.date}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    
                    // Email body
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedEmail!.body,
                              style: const TextStyle(fontSize: 14, height: 1.5),
                            ),
                            const SizedBox(height: 16),
                            
                            // Action buttons
                            if (_selectedEmail!.status == 'Un-Processed')
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _processEmail(_selectedEmail!.emailId),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: const Text('Process'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _rejectEmail(_selectedEmail!.emailId),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: const Text('Reject'),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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