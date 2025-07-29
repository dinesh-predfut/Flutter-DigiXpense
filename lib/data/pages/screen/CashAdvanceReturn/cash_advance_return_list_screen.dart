import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digi_xpense/core/services/new_screens_api_service.dart';
import 'package:digi_xpense/core/models/new_screens_models.dart';
import 'package:digi_xpense/core/constant/Parames/params.dart';
import 'package:intl/intl.dart';

class CashAdvanceReturnListScreen extends StatefulWidget {
  const CashAdvanceReturnListScreen({Key? key}) : super(key: key);

  @override
  State<CashAdvanceReturnListScreen> createState() => _CashAdvanceReturnListScreenState();
}

class _CashAdvanceReturnListScreenState extends State<CashAdvanceReturnListScreen> {
  final NewScreensApiService _apiService = NewScreensApiService();
  final TextEditingController _searchController = TextEditingController();
  
  List<CashAdvanceReturnModel> _returns = [];
  List<CashAdvanceReturnModel> _filteredReturns = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  
  final List<String> _filterOptions = ['All', 'Pending', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _loadCashAdvanceReturns();
  }

  Future<void> _loadCashAdvanceReturns() async {
    try {
      setState(() => _isLoading = true);
      final returns = await _apiService.getCashAdvanceReturnList();
      setState(() {
        _returns = returns;
        _filteredReturns = returns;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading cash advance returns: $e')),
      );
    }
  }

  void _filterReturns(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'All') {
        _filteredReturns = _returns;
      } else {
        _filteredReturns = _returns.where((ret) => ret.status == filter).toList();
      }
    });
  }

  void _searchReturns(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredReturns = _returns;
      } else {
        _filteredReturns = _returns.where((ret) =>
          ret.returnId.toLowerCase().contains(query.toLowerCase()) ||
          ret.employeeName.toLowerCase().contains(query.toLowerCase()) ||
          ret.projectName.toLowerCase().contains(query.toLowerCase())
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Cash Advance Return',
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
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              // Navigate to create cash advance return screen
              // Get.to(() => CreateCashAdvanceReturnScreen());
            },
          ),
        ],
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
                  'Cash Advance Returns',
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
              onChanged: _searchReturns,
              decoration: InputDecoration(
                hintText: 'Search in Cash Advance Returns',
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
                      onPressed: () => _filterReturns(filter),
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
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Returns list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredReturns.isEmpty
                    ? const Center(
                        child: Text(
                          'No cash advance returns found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadCashAdvanceReturns,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredReturns.length,
                          itemBuilder: (context, index) {
                            final returnItem = _filteredReturns[index];
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
                                  child: Text(
                                    returnItem.employeeName.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  returnItem.employeeName,
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
                                      'Return ID: ${returnItem.returnId}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Project: ${returnItem.projectName}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Amount: ₹${returnItem.returnAmount.toStringAsFixed(2)}',
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
                                          _getStatusColor(returnItem.status).replaceAll('#', '0xFF'),
                                        )),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        returnItem.status,
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
                                        DateTime.parse(returnItem.returnDate),
                                      ),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // Navigate to detail screen
                                  // Get.to(() => CashAdvanceReturnDetailScreen(returnItem));
                                },
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