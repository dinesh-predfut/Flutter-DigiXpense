// Models for new screens

// Cash Advance Return Models
class CashAdvanceReturnModel {
  final String returnId;
  final String employeeId;
  final String employeeName;
  final double returnAmount;
  final String returnDate;
  final String paymentMethod;
  final String cashAdvanceRequestId;
  final String status;
  final String projectId;
  final String projectName;
  final String comments;
  final List<CashAdvanceReturnItemModel> items;
  final List<ApprovalHistoryModel> approvalHistory;

  CashAdvanceReturnModel({
    required this.returnId,
    required this.employeeId,
    required this.employeeName,
    required this.returnAmount,
    required this.returnDate,
    required this.paymentMethod,
    required this.cashAdvanceRequestId,
    required this.status,
    required this.projectId,
    required this.projectName,
    required this.comments,
    required this.items,
    required this.approvalHistory,
  });

  factory CashAdvanceReturnModel.fromJson(Map<String, dynamic> json) {
    return CashAdvanceReturnModel(
      returnId: json['ReturnId'] ?? '',
      employeeId: json['EmployeeId'] ?? '',
      employeeName: json['EmployeeName'] ?? '',
      returnAmount: (json['ReturnAmount'] ?? 0.0).toDouble(),
      returnDate: json['ReturnDate'] ?? '',
      paymentMethod: json['PaymentMethod'] ?? '',
      cashAdvanceRequestId: json['CashAdvanceRequestId'] ?? '',
      status: json['Status'] ?? '',
      projectId: json['ProjectId'] ?? '',
      projectName: json['ProjectName'] ?? '',
      comments: json['Comments'] ?? '',
      items: (json['Items'] as List<dynamic>?)
          ?.map((item) => CashAdvanceReturnItemModel.fromJson(item))
          .toList() ?? [],
      approvalHistory: (json['ApprovalHistory'] as List<dynamic>?)
          ?.map((history) => ApprovalHistoryModel.fromJson(history))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ReturnId': returnId,
      'EmployeeId': employeeId,
      'EmployeeName': employeeName,
      'ReturnAmount': returnAmount,
      'ReturnDate': returnDate,
      'PaymentMethod': paymentMethod,
      'CashAdvanceRequestId': cashAdvanceRequestId,
      'Status': status,
      'ProjectId': projectId,
      'ProjectName': projectName,
      'Comments': comments,
      'Items': items.map((item) => item.toJson()).toList(),
      'ApprovalHistory': approvalHistory.map((history) => history.toJson()).toList(),
    };
  }
}

class CashAdvanceReturnItemModel {
  final String itemId;
  final String projectId;
  final String projectName;
  final String paidFor;
  final String comments;
  final double unit;
  final double quantity;
  final double unitAmount;
  final double lineAmount;
  final String taxGroup;
  final double taxAmount;

  CashAdvanceReturnItemModel({
    required this.itemId,
    required this.projectId,
    required this.projectName,
    required this.paidFor,
    required this.comments,
    required this.unit,
    required this.quantity,
    required this.unitAmount,
    required this.lineAmount,
    required this.taxGroup,
    required this.taxAmount,
  });

  factory CashAdvanceReturnItemModel.fromJson(Map<String, dynamic> json) {
    return CashAdvanceReturnItemModel(
      itemId: json['ItemId'] ?? '',
      projectId: json['ProjectId'] ?? '',
      projectName: json['ProjectName'] ?? '',
      paidFor: json['PaidFor'] ?? '',
      comments: json['Comments'] ?? '',
      unit: (json['Unit'] ?? 0.0).toDouble(),
      quantity: (json['Quantity'] ?? 0.0).toDouble(),
      unitAmount: (json['UnitAmount'] ?? 0.0).toDouble(),
      lineAmount: (json['LineAmount'] ?? 0.0).toDouble(),
      taxGroup: json['TaxGroup'] ?? '',
      taxAmount: (json['TaxAmount'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ItemId': itemId,
      'ProjectId': projectId,
      'ProjectName': projectName,
      'PaidFor': paidFor,
      'Comments': comments,
      'Unit': unit,
      'Quantity': quantity,
      'UnitAmount': unitAmount,
      'LineAmount': lineAmount,
      'TaxGroup': taxGroup,
      'TaxAmount': taxAmount,
    };
  }
}

// Email Hub Models
class EmailHubModel {
  final String emailId;
  final String from;
  final String to;
  final String subject;
  final String body;
  final String date;
  final String status; // Processed, Un-Processed, Rejected
  final String senderName;
  final String senderInitials;
  final String timestamp;

  EmailHubModel({
    required this.emailId,
    required this.from,
    required this.to,
    required this.subject,
    required this.body,
    required this.date,
    required this.status,
    required this.senderName,
    required this.senderInitials,
    required this.timestamp,
  });

  factory EmailHubModel.fromJson(Map<String, dynamic> json) {
    return EmailHubModel(
      emailId: json['EmailId'] ?? '',
      from: json['From'] ?? '',
      to: json['To'] ?? '',
      subject: json['Subject'] ?? '',
      body: json['Body'] ?? '',
      date: json['Date'] ?? '',
      status: json['Status'] ?? '',
      senderName: json['SenderName'] ?? '',
      senderInitials: json['SenderInitials'] ?? '',
      timestamp: json['Timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EmailId': emailId,
      'From': from,
      'To': to,
      'Subject': subject,
      'Body': body,
      'Date': date,
      'Status': status,
      'SenderName': senderName,
      'SenderInitials': senderInitials,
      'Timestamp': timestamp,
    };
  }
}

// Approval Hub Models
class ApprovalHubModel {
  final String approvalId;
  final String expenseId;
  final String employeeId;
  final String employeeName;
  final String expenseType; // General Expense, Per Diem, Mileage, Cash Advance Return
  final double amount;
  final String status;
  final String projectId;
  final String projectName;
  final String receiptDate;
  final String paymentMethod;
  final String paidTo;
  final List<ApprovalItemModel> items;
  final List<ApprovalHistoryModel> approvalHistory;
  final List<PolicyViolationModel> policyViolations;

  ApprovalHubModel({
    required this.approvalId,
    required this.expenseId,
    required this.employeeId,
    required this.employeeName,
    required this.expenseType,
    required this.amount,
    required this.status,
    required this.projectId,
    required this.projectName,
    required this.receiptDate,
    required this.paymentMethod,
    required this.paidTo,
    required this.items,
    required this.approvalHistory,
    required this.policyViolations,
  });

  factory ApprovalHubModel.fromJson(Map<String, dynamic> json) {
    return ApprovalHubModel(
      approvalId: json['ApprovalId'] ?? '',
      expenseId: json['ExpenseId'] ?? '',
      employeeId: json['EmployeeId'] ?? '',
      employeeName: json['EmployeeName'] ?? '',
      expenseType: json['ExpenseType'] ?? '',
      amount: (json['Amount'] ?? 0.0).toDouble(),
      status: json['Status'] ?? '',
      projectId: json['ProjectId'] ?? '',
      projectName: json['ProjectName'] ?? '',
      receiptDate: json['ReceiptDate'] ?? '',
      paymentMethod: json['PaymentMethod'] ?? '',
      paidTo: json['PaidTo'] ?? '',
      items: (json['Items'] as List<dynamic>?)
          ?.map((item) => ApprovalItemModel.fromJson(item))
          .toList() ?? [],
      approvalHistory: (json['ApprovalHistory'] as List<dynamic>?)
          ?.map((history) => ApprovalHistoryModel.fromJson(history))
          .toList() ?? [],
      policyViolations: (json['PolicyViolations'] as List<dynamic>?)
          ?.map((violation) => PolicyViolationModel.fromJson(violation))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ApprovalId': approvalId,
      'ExpenseId': expenseId,
      'EmployeeId': employeeId,
      'EmployeeName': employeeName,
      'ExpenseType': expenseType,
      'Amount': amount,
      'Status': status,
      'ProjectId': projectId,
      'ProjectName': projectName,
      'ReceiptDate': receiptDate,
      'PaymentMethod': paymentMethod,
      'PaidTo': paidTo,
      'Items': items.map((item) => item.toJson()).toList(),
      'ApprovalHistory': approvalHistory.map((history) => history.toJson()).toList(),
      'PolicyViolations': policyViolations.map((violation) => violation.toJson()).toList(),
    };
  }
}

class ApprovalItemModel {
  final String itemId;
  final String projectId;
  final String projectName;
  final String paidFor;
  final String comments;
  final double unit;
  final double quantity;
  final double unitAmount;
  final double lineAmount;
  final String taxGroup;
  final double taxAmount;
  final bool isReimbursable;
  final bool isBillable;

  ApprovalItemModel({
    required this.itemId,
    required this.projectId,
    required this.projectName,
    required this.paidFor,
    required this.comments,
    required this.unit,
    required this.quantity,
    required this.unitAmount,
    required this.lineAmount,
    required this.taxGroup,
    required this.taxAmount,
    required this.isReimbursable,
    required this.isBillable,
  });

  factory ApprovalItemModel.fromJson(Map<String, dynamic> json) {
    return ApprovalItemModel(
      itemId: json['ItemId'] ?? '',
      projectId: json['ProjectId'] ?? '',
      projectName: json['ProjectName'] ?? '',
      paidFor: json['PaidFor'] ?? '',
      comments: json['Comments'] ?? '',
      unit: (json['Unit'] ?? 0.0).toDouble(),
      quantity: (json['Quantity'] ?? 0.0).toDouble(),
      unitAmount: (json['UnitAmount'] ?? 0.0).toDouble(),
      lineAmount: (json['LineAmount'] ?? 0.0).toDouble(),
      taxGroup: json['TaxGroup'] ?? '',
      taxAmount: (json['TaxAmount'] ?? 0.0).toDouble(),
      isReimbursable: json['IsReimbursable'] ?? false,
      isBillable: json['IsBillable'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ItemId': itemId,
      'ProjectId': projectId,
      'ProjectName': projectName,
      'PaidFor': paidFor,
      'Comments': comments,
      'Unit': unit,
      'Quantity': quantity,
      'UnitAmount': unitAmount,
      'LineAmount': lineAmount,
      'TaxGroup': taxGroup,
      'TaxAmount': taxAmount,
      'IsReimbursable': isReimbursable,
      'IsBillable': isBillable,
    };
  }
}

class PolicyViolationModel {
  final String policyId;
  final String policyName;
  final String violationType; // Pass, Fail, Warning
  final String description;

  PolicyViolationModel({
    required this.policyId,
    required this.policyName,
    required this.violationType,
    required this.description,
  });

  factory PolicyViolationModel.fromJson(Map<String, dynamic> json) {
    return PolicyViolationModel(
      policyId: json['PolicyId'] ?? '',
      policyName: json['PolicyName'] ?? '',
      violationType: json['ViolationType'] ?? '',
      description: json['Description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PolicyId': policyId,
      'PolicyName': policyName,
      'ViolationType': violationType,
      'Description': description,
    };
  }
}

class ApprovalHistoryModel {
  final String stage;
  final String status;
  final String date;
  final String approver;
  final String comments;

  ApprovalHistoryModel({
    required this.stage,
    required this.status,
    required this.date,
    required this.approver,
    required this.comments,
  });

  factory ApprovalHistoryModel.fromJson(Map<String, dynamic> json) {
    return ApprovalHistoryModel(
      stage: json['Stage'] ?? '',
      status: json['Status'] ?? '',
      date: json['Date'] ?? '',
      approver: json['Approver'] ?? '',
      comments: json['Comments'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Stage': stage,
      'Status': status,
      'Date': date,
      'Approver': approver,
      'Comments': comments,
    };
  }
}

// My Team Models
class MyTeamExpenseModel {
  final String expenseId;
  final String employeeId;
  final String employeeName;
  final double amount;
  final String status;
  final String date;
  final String projectId;
  final String projectName;
  final String expenseType;

  MyTeamExpenseModel({
    required this.expenseId,
    required this.employeeId,
    required this.employeeName,
    required this.amount,
    required this.status,
    required this.date,
    required this.projectId,
    required this.projectName,
    required this.expenseType,
  });

  factory MyTeamExpenseModel.fromJson(Map<String, dynamic> json) {
    return MyTeamExpenseModel(
      expenseId: json['ExpenseId'] ?? '',
      employeeId: json['EmployeeId'] ?? '',
      employeeName: json['EmployeeName'] ?? '',
      amount: (json['Amount'] ?? 0.0).toDouble(),
      status: json['Status'] ?? '',
      date: json['Date'] ?? '',
      projectId: json['ProjectId'] ?? '',
      projectName: json['ProjectName'] ?? '',
      expenseType: json['ExpenseType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ExpenseId': expenseId,
      'EmployeeId': employeeId,
      'EmployeeName': employeeName,
      'Amount': amount,
      'Status': status,
      'Date': date,
      'ProjectId': projectId,
      'ProjectName': projectName,
      'ExpenseType': expenseType,
    };
  }
}

class MyTeamCashAdvanceModel {
  final String cashAdvanceId;
  final String employeeId;
  final String employeeName;
  final double amount;
  final String status;
  final String date;
  final String projectId;
  final String projectName;
  final String businessJustification;

  MyTeamCashAdvanceModel({
    required this.cashAdvanceId,
    required this.employeeId,
    required this.employeeName,
    required this.amount,
    required this.status,
    required this.date,
    required this.projectId,
    required this.projectName,
    required this.businessJustification,
  });

  factory MyTeamCashAdvanceModel.fromJson(Map<String, dynamic> json) {
    return MyTeamCashAdvanceModel(
      cashAdvanceId: json['CashAdvanceId'] ?? '',
      employeeId: json['EmployeeId'] ?? '',
      employeeName: json['EmployeeName'] ?? '',
      amount: (json['Amount'] ?? 0.0).toDouble(),
      status: json['Status'] ?? '',
      date: json['Date'] ?? '',
      projectId: json['ProjectId'] ?? '',
      projectName: json['ProjectName'] ?? '',
      businessJustification: json['BusinessJustification'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CashAdvanceId': cashAdvanceId,
      'EmployeeId': employeeId,
      'EmployeeName': employeeName,
      'Amount': amount,
      'Status': status,
      'Date': date,
      'ProjectId': projectId,
      'ProjectName': projectName,
      'BusinessJustification': businessJustification,
    };
  }
} 