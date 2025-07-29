import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digi_xpense/core/services/new_screens_api_service.dart';
import 'package:digi_xpense/core/models/new_screens_models.dart';
import 'package:digi_xpense/core/constant/Parames/params.dart';
import 'package:intl/intl.dart';

class MyTeamExpenseScreen extends StatefulWidget {
  const MyTeamExpenseScreen({Key? key}) : super(key: key);

  @override
  State<MyTeamExpenseScreen> createState() => _MyTeamExpenseScreenState();
}

class _MyTeamExpenseScreenState extends State<MyTeamExpenseScreen> {
  final NewScreensApiService _apiService = NewScreensApiService();
  final TextEditingController _searchController = TextEditingController();
  
  List<MyTeamExpenseModel> _expenses = [];
  List<MyTeamExpenseModel> _filteredExpenses = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  Map<String, dynamic>? _summaryData;
  
  final List<String> _filterOptions = ['All', 'In Process', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      // Load both expenses and summary data
      final futures = await Future.wait([
        _apiService.getMyTeamExpenseList(),
        _apiService.getMyTeamExpenseSummary(),
      ]);
      
      setState(() {
        _expenses = futures[0] as List<MyTeamExpenseModel>;
        _filteredExpenses = _expenses;
        _summaryData = futures[1] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading team expenses: $e')),
      );
    }
  }

  void _filterExpenses(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'All') {
        _filteredExpenses = _expenses;
      } else {
        _filteredExpenses = _expenses.where((expense) => expense.status == filter).toList();
      }
    });
  }

  void _searchExpenses(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredExpenses = _expenses;
      } else {
        _filteredExpenses = _expenses.where((expense) =>
          expense.expenseId.toLowerCase().contains(query.toLowerCase()) ||
          expense.employeeName.toLowerCase().contains(query.toLowerCase()) ||
          expense.projectName.toLowerCase().contains(query.toLowerCase())
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
      case 'in process':
        return '#FF9800';
      case 'un reported':
        return '#FF9800';
      default:
        return '#9E9E9E';
    }
  }

  void _showExpenseDetails(MyTeamExpenseModel expense) async {
    try {
      final details = await _apiService.getMyTeamExpenseDetails(expense.expenseId);
      // Navigate to detail screen with the data
      // Get.to(() => MyTeamExpenseDetailScreen(details));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading expense details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Team Expense',
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
                  'My Team Expense',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Summary cards
          if (_summaryData != null)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Balance to spend by category',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${_summaryData!['totalBalance']?.toString() ?? '0'}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Balance to spend by category',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${_summaryData!['totalBalance']?.toString() ?? '0'}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
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
              onChanged: _searchExpenses,
              decoration: InputDecoration(
                hintText: 'Search team expenses',
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
                      onPressed: () => _filterExpenses(filter),
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
          
          // Un Reported List section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.list, color: Colors.grey),
                const SizedBox(width: 8),
                const Text(
                  'Un Reported List',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Expenses list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredExpenses.isEmpty
                    ? const Center(
                        child: Text(
                          'No team expenses found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredExpenses.length,
                          itemBuilder: (context, index) {
                            final expense = _filteredExpenses[index];
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
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.receipt,
                                    color: Colors.grey,
                                  ),
                                ),
                                title: Text(
                                  expense.expenseId,
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
                                      expense.employeeName,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Project: ${expense.projectName}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Type: ${expense.expenseType}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Amount: ₹${expense.amount.toStringAsFixed(2)}',
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
                                          _getStatusColor(expense.status).replaceAll('#', '0xFF'),
                                        )),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        expense.status,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('dd-MM-yyyy').format(
                                        DateTime.parse(expense.date),
                                      ),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () => _showExpenseDetails(expense),
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