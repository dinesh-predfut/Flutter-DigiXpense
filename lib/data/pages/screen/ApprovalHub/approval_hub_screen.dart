import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digi_xpense/core/services/new_screens_api_service.dart';
import 'package:digi_xpense/core/models/new_screens_models.dart';
import 'package:digi_xpense/core/constant/Parames/params.dart';
import 'package:intl/intl.dart';

class ApprovalHubScreen extends StatefulWidget {
  const ApprovalHubScreen({Key? key}) : super(key: key);

  @override
  State<ApprovalHubScreen> createState() => _ApprovalHubScreenState();
}

class _ApprovalHubScreenState extends State<ApprovalHubScreen> {
  final NewScreensApiService _apiService = NewScreensApiService();
  final TextEditingController _searchController = TextEditingController();
  
  List<ApprovalHubModel> _approvals = [];
  List<ApprovalHubModel> _filteredApprovals = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  
  final List<String> _filterOptions = ['All', 'General Expense', 'Per Diem', 'Mileage', 'Cash Advance Return'];

  @override
  void initState() {
    super.initState();
    _loadApprovals();
  }

  Future<void> _loadApprovals() async {
    try {
      setState(() => _isLoading = true);
      final approvals = await _apiService.getApprovalHubList();
      setState(() {
        _approvals = approvals;
        _filteredApprovals = approvals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading approvals: $e')),
      );
    }
  }

  void _filterApprovals(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'All') {
        _filteredApprovals = _approvals;
      } else {
        _filteredApprovals = _approvals.where((approval) => approval.expenseType == filter).toList();
      }
    });
  }

  void _searchApprovals(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredApprovals = _approvals;
      } else {
        _filteredApprovals = _approvals.where((approval) =>
          approval.employeeName.toLowerCase().contains(query.toLowerCase()) ||
          approval.expenseId.toLowerCase().contains(query.toLowerCase()) ||
          approval.projectName.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    });
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return '#4CAF50';
      case 'rejected':
        return '#F44336';
      case 'pending':
        return '#FF9800';
      default:
        return '#9E9E9E';
    }
  }

  IconData _getExpenseTypeIcon(String expenseType) {
    switch (expenseType.toLowerCase()) {
      case 'general expense':
        return Icons.receipt;
      case 'per diem':
        return Icons.hotel;
      case 'mileage':
        return Icons.directions_car;
      case 'cash advance return':
        return Icons.arrow_back;
      default:
        return Icons.description;
    }
  }

  void _showApprovalActions(ApprovalHubModel approval) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildApprovalActionsSheet(approval),
    );
  }

  Widget _buildApprovalActionsSheet(ApprovalHubModel approval) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Approval Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Approval details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expense ID: ${approval.expenseId}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Employee: ${approval.employeeName}'),
                        Text('Amount: ₹${approval.amount.toStringAsFixed(2)}'),
                        Text('Type: ${approval.expenseType}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _approveExpense(approval.approvalId),
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text('Approve', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _rejectExpense(approval.approvalId),
                          icon: const Icon(Icons.close, color: Colors.white),
                          label: const Text('Reject', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _escalateExpense(approval.approvalId),
                          icon: const Icon(Icons.arrow_upward, color: Colors.white),
                          label: const Text('Escalate', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _skipExpense(approval.approvalId),
                          icon: const Icon(Icons.skip_next, color: Colors.white),
                          label: const Text('Skip', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approveExpense(String approvalId) async {
    try {
      await _apiService.approveExpense(approvalId, 'Approved');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense approved successfully')),
      );
      _loadApprovals();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving expense: $e')),
      );
    }
  }

  Future<void> _rejectExpense(String approvalId) async {
    final comments = await _showCommentsDialog('Reject');
    if (comments != null) {
      try {
        await _apiService.rejectExpense(approvalId, comments);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense rejected successfully')),
        );
        _loadApprovals();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting expense: $e')),
        );
      }
    }
  }

  Future<void> _escalateExpense(String approvalId) async {
    final escalatedTo = await _showEscalateDialog();
    if (escalatedTo != null) {
      final comments = await _showCommentsDialog('Escalate');
      if (comments != null) {
        try {
          await _apiService.escalateExpense(approvalId, escalatedTo, comments);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense escalated successfully')),
          );
          _loadApprovals();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error escalating expense: $e')),
          );
        }
      }
    }
  }

  Future<void> _skipExpense(String approvalId) async {
    final comments = await _showCommentsDialog('Skip');
    if (comments != null) {
      try {
        await _apiService.skipExpense(approvalId, comments);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense skipped successfully')),
        );
        _loadApprovals();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error skipping expense: $e')),
        );
      }
    }
  }

  Future<String?> _showCommentsDialog(String action) async {
    final TextEditingController commentsController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action Expense'),
        content: TextField(
          controller: commentsController,
          decoration: InputDecoration(
            labelText: 'Comments for $action',
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, commentsController.text),
            child: Text(action),
          ),
        ],
      ),
    );
  }

  Future<String?> _showEscalateDialog() async {
    // This would typically fetch from API
    final List<String> users = ['Manager 1', 'Manager 2', 'Director', 'VP'];
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escalate To'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(users[index]),
                onTap: () => Navigator.pop(context, users[index]),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
          'Approval Hub',
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
      ),
      body: Column(
        children: [
          // Header with greeting
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF6A4C93),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Good Morning, ${Params.userName ?? 'User'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white24,
                      child: Text(
                        (Params.userName ?? 'U').substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pending Approvals',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchApprovals,
              decoration: InputDecoration(
                hintText: 'Search approvals',
                prefixIcon: const Icon(Icons.search),
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
                      onPressed: () => _filterApprovals(filter),
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
          
          // Approvals list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredApprovals.isEmpty
                    ? const Center(
                        child: Text(
                          'No pending approvals found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadApprovals,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredApprovals.length,
                          itemBuilder: (context, index) {
                            final approval = _filteredApprovals[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
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
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.grey[200],
                                  child: Icon(
                                    _getExpenseTypeIcon(approval.expenseType),
                                    color: Colors.grey[700],
                                  ),
                                ),
                                title: Text(
                                  approval.employeeName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      'Expense ID: ${approval.expenseId}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Type: ${approval.expenseType}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Amount: ₹${approval.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(int.parse(
                                          _getStatusColor(approval.status).replaceAll('#', '0xFF'),
                                        )),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        approval.status,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('dd MMM').format(
                                        DateTime.parse(approval.receiptDate),
                                      ),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () => _showApprovalActions(approval),
                              ),
                            );
                          },
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