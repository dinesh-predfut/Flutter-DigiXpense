import 'package:digi_xpense/core/services/api_service.dart';
import 'package:digi_xpense/core/constant/url.dart';
import 'package:digi_xpense/core/models/new_screens_models.dart';

class NewScreensApiService {
  static final NewScreensApiService _instance = NewScreensApiService._internal();
  factory NewScreensApiService() => _instance;
  NewScreensApiService._internal();

  final ApiService _apiService = ApiService();

  // Cash Advance Return APIs
  Future<List<CashAdvanceReturnModel>> getCashAdvanceReturnList() async {
    try {
      final response = await _apiService.get(Urls.cashAdvanceReturnList);
      final data = _apiService.handleResponse(response);
      
      if (data['data'] != null) {
        return (data['data'] as List)
            .map((item) => CashAdvanceReturnModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch cash advance return list: $e');
    }
  }

  Future<CashAdvanceReturnModel> getCashAdvanceReturn(String returnId) async {
    try {
      final response = await _apiService.get('${Urls.cashAdvanceReturnGet}ReturnId=$returnId');
      final data = _apiService.handleResponse(response);
      return CashAdvanceReturnModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch cash advance return: $e');
    }
  }

  Future<void> createCashAdvanceReturn(Map<String, dynamic> payload) async {
    try {
      final response = await _apiService.post(
        Urls.cashAdvanceReturnCreate,
        body: payload,
      );
      _apiService.handleResponse(response);
    } catch (e) {
      throw Exception('Failed to create cash advance return: $e');
    }
  }

  Future<void> updateCashAdvanceReturn(Map<String, dynamic> payload) async {
    try {
      final response = await _apiService.put(
        Urls.cashAdvanceReturnUpdate,
        body: payload,
      );
      _apiService.handleResponse(response);
    } catch (e) {
      throw Exception('Failed to update cash advance return: $e');
    }
  }

  // Email Hub APIs (Forward Email Management)
  Future<List<EmailHubModel>> getEmailHubList({String? status}) async {
    try {
      String url = Urls.emailHubList;
      if (status != null && status.isNotEmpty && status != 'All') {
        url += '?status=$status';
      }
      
      final response = await _apiService.get(url);
      final data = _apiService.handleResponse(response);
      
      if (data['data'] != null) {
        return (data['data'] as List)
            .map((item) => EmailHubModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch email hub list: $e');
    }
  }

  Future<EmailHubModel> getSpecificEmail(String emailId) async {
    try {
      final response = await _apiService.get('${Urls.emailHubGetSpecific}?emailId=$emailId');
      final data = _apiService.handleResponse(response);
      
      if (data['data'] != null) {
        return EmailHubModel.fromJson(data['data']);
      }
      throw Exception('Email not found');
    } catch (e) {
      throw Exception('Failed to fetch specific email: $e');
    }
  }

  Future<void> processEmail(String emailId) async {
    try {
      final payload = {
        'emailId': emailId,
        'action': 'process',
      };
      
      final response = await _apiService.post(
        Urls.emailHubProcess,
        body: payload,
      );
      _apiService.handleResponse(response);
    } catch (e) {
      throw Exception('Failed to process email: $e');
    }
  }

  Future<void> rejectEmail(String emailId, String reason) async {
    try {
      final payload = {
        'emailId': emailId,
        'action': 'reject',
        'reason': reason,
      };
      
      final response = await _apiService.post(
        Urls.emailHubReject,
        body: payload,
      );
      _apiService.handleResponse(response);
    } catch (e) {
      throw Exception('Failed to reject email: $e');
    }
  }

  // Approval Hub APIs
  Future<List<ApprovalHubModel>> getApprovalHubList({String? expenseType}) async {
    try {
      String url = Urls.pendingApprovals;
      if (expenseType != null && expenseType.isNotEmpty) {
        url += '&ExpenseType=$expenseType';
      }
      
      final response = await _apiService.get(url);
      final data = _apiService.handleResponse(response);
      
      if (data['data'] != null) {
        return (data['data'] as List)
            .map((item) => ApprovalHubModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch approval hub list: $e');
    }
  }

  Future<void> approveExpense(String approvalId, String comments) async {
    try {
      final payload = {
        'ApprovalId': approvalId,
        'Action': 'Approve',
        'Comments': comments,
      };
      
      final response = await _apiService.post(
        Urls.updateApprovalStatus,
        body: payload,
      );
      _apiService.handleResponse(response);
    } catch (e) {
      throw Exception('Failed to approve expense: $e');
    }
  }

  Future<void> rejectExpense(String approvalId, String comments) async {
    try {
      final payload = {
        'ApprovalId': approvalId,
        'Action': 'Reject',
        'Comments': comments,
      };
      
      final response = await _apiService.post(
        Urls.updateApprovalStatus,
        body: payload,
      );
      _apiService.handleResponse(response);
    } catch (e) {
      throw Exception('Failed to reject expense: $e');
    }
  }

  Future<void> escalateExpense(String approvalId, String escalatedTo, String comments) async {
    try {
      final payload = {
        'ApprovalId': approvalId,
        'Action': 'Escalate',
        'EscalatedTo': escalatedTo,
        'Comments': comments,
      };
      
      final response = await _apiService.post(
        Urls.updateApprovalStatus,
        body: payload,
      );
      _apiService.handleResponse(response);
    } catch (e) {
      throw Exception('Failed to escalate expense: $e');
    }
  }

  Future<void> skipExpense(String approvalId, String comments) async {
    try {
      final payload = {
        'ApprovalId': approvalId,
        'Action': 'Skip',
        'Comments': comments,
      };
      
      final response = await _apiService.post(
        Urls.updateApprovalStatus,
        body: payload,
      );
      _apiService.handleResponse(response);
    } catch (e) {
      throw Exception('Failed to skip expense: $e');
    }
  }

  // My Team Expense APIs
  Future<List<MyTeamExpenseModel>> getMyTeamExpenseList({String? status}) async {
    try {
      String url = Urls.myTeamExpenseList;
      if (status != null && status.isNotEmpty) {
        url += '&Status=$status';
      }
      
      final response = await _apiService.get(url);
      final data = _apiService.handleResponse(response);
      
      if (data['data'] != null) {
        return (data['data'] as List)
            .map((item) => MyTeamExpenseModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch my team expense list: $e');
    }
  }

  Future<Map<String, dynamic>> getMyTeamExpenseDetails(String expenseId) async {
    try {
      final response = await _apiService.get('${Urls.myTeamExpenseGet}ExpenseId=$expenseId');
      return _apiService.handleResponse(response);
    } catch (e) {
      throw Exception('Failed to fetch my team expense details: $e');
    }
  }

  // My Team Cash Advance APIs
  Future<List<MyTeamCashAdvanceModel>> getMyTeamCashAdvanceList({String? status}) async {
    try {
      String url = Urls.myTeamCashAdvanceList;
      if (status != null && status.isNotEmpty) {
        url += '&Status=$status';
      }
      
      final response = await _apiService.get(url);
      final data = _apiService.handleResponse(response);
      
      if (data['data'] != null) {
        return (data['data'] as List)
            .map((item) => MyTeamCashAdvanceModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch my team cash advance list: $e');
    }
  }

  Future<Map<String, dynamic>> getMyTeamCashAdvanceDetails(String cashAdvanceId) async {
    try {
      final response = await _apiService.get('${Urls.myTeamCashAdvanceGet}CashAdvanceId=$cashAdvanceId');
      return _apiService.handleResponse(response);
    } catch (e) {
      throw Exception('Failed to fetch my team cash advance details: $e');
    }
  }

  // Dashboard Summary APIs
  Future<Map<String, dynamic>> getMyTeamExpenseSummary() async {
    try {
      final response = await _apiService.get('${Urls.myTeamExpenseList}&summary=true');
      return _apiService.handleResponse(response);
    } catch (e) {
      throw Exception('Failed to fetch my team expense summary: $e');
    }
  }

  Future<Map<String, dynamic>> getMyTeamCashAdvanceSummary() async {
    try {
      final response = await _apiService.get('${Urls.myTeamCashAdvanceList}&summary=true');
      return _apiService.handleResponse(response);
    } catch (e) {
      throw Exception('Failed to fetch my team cash advance summary: $e');
    }
  }
} 