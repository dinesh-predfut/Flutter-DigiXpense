import 'dart:math';
import 'dart:ui';

class Country {
  final String code;
  final String name;

  Country({required this.code, required this.name});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      code: json['CountryCode'],
      name: json['CountryName'],
    );
  }
}

// models/field_configuration.dart
class FieldConfiguration {
  final String fieldId;
  final String fieldName;
  final bool isEnabled;
  final bool isMandatory;
  final String functionalArea;
  final int recId;

  FieldConfiguration({
    required this.fieldId,
    required this.fieldName,
    required this.isEnabled,
    required this.isMandatory,
    required this.functionalArea,
    required this.recId,
  });

  factory FieldConfiguration.fromJson(Map<String, dynamic> json) {
    return FieldConfiguration(
      fieldId: json['FieldId'] ?? '',
      fieldName: json['FieldName'] ?? '',
      isEnabled: json['IsEnabled'] == true,
      isMandatory: json['IsMandatory'] == true,
      functionalArea: json['FunctionalArea'] ?? '',
      recId: json['RecId'] ?? 0,
    );
  }
}

class Businessjustification {
  final String id;
  final String name;
  final String merchantId;

  Businessjustification({
    required this.id,
    required this.name,
    required this.merchantId,
  });

  factory Businessjustification.fromJson(Map<String, dynamic> json) {
    return Businessjustification(
      id: json['RecId'].toString(),
      name: json['Name'] ?? '',
      merchantId: json['Id'].toString(),
    );
  }
}

class CashAdvanceModel {
  final String requisitionId;
  final String employeeId;
  final String employeeName;
  final double totalRequestedAmountInReporting;
  final double totalEstimatedAmountInReporting;
  final String approvalStatus;
  final String businessJustification;
  final String createdBy;
  final String modifiedBy;
  final int organizationId;
  final int recId;
  final int requestDate;
  final double? totalRequestedAmount;
  final double? totalEstimatedAmount;
  final double totalApprovedAmount;
  final double totalRejectedAmount;
  final double amountSettled;
  final String? description;
  final String? expenseCategoryId;
  final String? prefferedPaymentMethod;
  final double? percentage;
  final String? location;
  final int createdDatetime;
  final int modifiedDatetime;
  final int subOrganizationId;
  final String? projectId;
  final String? estimatedCurrency;
  final String? requestedCurrency;
  final double? requestedExchangerate;
  final double? estimatedExchangerate;
  final String? referenceId;
  final double amountPaid;
  final double amountPaidReporting;

  CashAdvanceModel({
    required this.requisitionId,
    required this.employeeId,
    required this.employeeName,
    required this.totalRequestedAmountInReporting,
    required this.totalEstimatedAmountInReporting,
    required this.approvalStatus,
    required this.businessJustification,
    required this.createdBy,
    required this.modifiedBy,
    required this.organizationId,
    required this.recId,
    required this.requestDate,
    this.totalRequestedAmount,
    this.totalEstimatedAmount,
    required this.totalApprovedAmount,
    required this.totalRejectedAmount,
    required this.amountSettled,
    this.description,
    this.expenseCategoryId,
    this.prefferedPaymentMethod,
    this.percentage,
    this.location,
    required this.createdDatetime,
    required this.modifiedDatetime,
    required this.subOrganizationId,
    this.projectId,
    this.estimatedCurrency,
    this.requestedCurrency,
    this.requestedExchangerate,
    this.estimatedExchangerate,
    this.referenceId,
    required this.amountPaid,
    required this.amountPaidReporting,
  });

  factory CashAdvanceModel.fromJson(Map<String, dynamic> json) {
    return CashAdvanceModel(
      requisitionId: json['RequisitionId'] ?? '',
      employeeId: json['EmployeeId'] ?? '',
      employeeName: json['EmployeeName'] ?? '',
      totalRequestedAmountInReporting:
          (json['TotalRequestedAmountInReporting'] ?? 0).toDouble(),
      totalEstimatedAmountInReporting:
          (json['TotalEstimatedAmountInReporting'] ?? 0).toDouble(),
      approvalStatus: json['ApprovalStatus'] ?? '',
      businessJustification: json['BusinessJustification'] ?? '',
      createdBy: json['CreatedBy'] ?? '',
      modifiedBy: json['ModifiedBy'] ?? '',
      organizationId: json['OrganizationId'] ?? 0,
      recId: json['RecId'] ?? 0,
      requestDate: json['RequestDate'] ?? 0,
      totalRequestedAmount: (json['TotalRequestedAmount'] as num?)?.toDouble(),
      totalEstimatedAmount: (json['TotalEstimatedAmount'] as num?)?.toDouble(),
      totalApprovedAmount: (json['TotalApprovedAmount'] ?? 0).toDouble(),
      totalRejectedAmount: (json['TotalRejectedAmount'] ?? 0).toDouble(),
      amountSettled: (json['AmountSettled'] ?? 0).toDouble(),
      description: json['Description'],
      expenseCategoryId: json['ExpenseCategoryId'],
      prefferedPaymentMethod: json['PrefferedPaymentMethod'],
      percentage: (json['Percentage'] as num?)?.toDouble(),
      location: json['Location'],
      createdDatetime: json['CreatedDatetime'] ?? 0,
      modifiedDatetime: json['ModifiedDatetime'] ?? 0,
      subOrganizationId: json['SubOrganizationId'] ?? 0,
      projectId: json['ProjectId'],
      estimatedCurrency: json['EstimatedCurrency'],
      requestedCurrency: json['RequestedCurrency'],
      requestedExchangerate:
          (json['RequestedExchangerate'] as num?)?.toDouble(),
      estimatedExchangerate:
          (json['EstimatedExchangerate'] as num?)?.toDouble(),
      referenceId: json['ReferenceId'],
      amountPaid: (json['AmountPaid'] ?? 0).toDouble(),
      amountPaidReporting: (json['AmountPaidReporting'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RequisitionId': requisitionId,
      'EmployeeId': employeeId,
      'EmployeeName': employeeName,
      'TotalRequestedAmountInReporting': totalRequestedAmountInReporting,
      'TotalEstimatedAmountInReporting': totalEstimatedAmountInReporting,
      'ApprovalStatus': approvalStatus,
      'BusinessJustification': businessJustification,
      'CreatedBy': createdBy,
      'ModifiedBy': modifiedBy,
      'OrganizationId': organizationId,
      'RecId': recId,
      'RequestDate': requestDate,
      'TotalRequestedAmount': totalRequestedAmount,
      'TotalEstimatedAmount': totalEstimatedAmount,
      'TotalApprovedAmount': totalApprovedAmount,
      'TotalRejectedAmount': totalRejectedAmount,
      'AmountSettled': amountSettled,
      'Description': description,
      'ExpenseCategoryId': expenseCategoryId,
      'PrefferedPaymentMethod': prefferedPaymentMethod,
      'Percentage': percentage,
      'Location': location,
      'CreatedDatetime': createdDatetime,
      'ModifiedDatetime': modifiedDatetime,
      'SubOrganizationId': subOrganizationId,
      'ProjectId': projectId,
      'EstimatedCurrency': estimatedCurrency,
      'RequestedCurrency': requestedCurrency,
      'RequestedExchangerate': requestedExchangerate,
      'EstimatedExchangerate': estimatedExchangerate,
      'ReferenceId': referenceId,
      'AmountPaid': amountPaid,
      'AmountPaidReporting': amountPaidReporting,
    };
  }
}

class ExpenseListModel {
  final String expenseId;
  final String expenseStatus;
  final double totalAmountTrans;
  final String employeeId;
  final DateTime? receiptDate;
  final String approvalStatus;
  final String currency;
  final String source;
  final double exchRate;
  final String createdBy;
  final String modifiedBy;
  final int organizationId;
  final int recId;
  final double totalAmountReporting;
  final String? projectId;
  final DateTime? fromDate;
  final DateTime? toDate;
  // final String? toDate;
  final String? paymentMethod;
  final String expenseCategoryId;
  final String? merchantName;
  final String? merchantId;
  final double? totalApprovedAmount;
  final double totalRejectedAmount;
  final double userExchRate;
  final String? country;
  final String? taxGroup;
  final double taxAmount;
  final String expenseType;
  final bool isReimbursable;
  final bool isBillable;
  final bool isPreauthorised;
  final int createdDatetime;
  final int modifiedDatetime;
  final int subOrganizationId;
  final String? employeeName;
  final int? closedDate;
  final int? lastSettlementDate;
  final double amountSettled;
  final String? referenceNumber;
  final String? description;
  final String? cashAdvReqId;
  final bool isDuplicated;
  final bool isForged;
  final bool isTobacco;
  final bool isAlcohol;
  final String? location;

  ExpenseListModel({
    required this.expenseId,
    required this.expenseStatus,
    required this.totalAmountTrans,
    required this.employeeId,
    this.receiptDate,
    required this.approvalStatus,
    required this.currency,
    required this.source,
    required this.exchRate,
    required this.createdBy,
    required this.modifiedBy,
    required this.organizationId,
    required this.recId,
    required this.totalAmountReporting,
    this.projectId,
    this.fromDate,
    this.toDate,
    this.paymentMethod,
    required this.expenseCategoryId,
    this.merchantName,
    this.merchantId,
    this.totalApprovedAmount,
    required this.totalRejectedAmount,
    required this.userExchRate,
    this.country,
    this.taxGroup,
    required this.taxAmount,
    required this.expenseType,
    required this.isReimbursable,
    required this.isBillable,
    required this.isPreauthorised,
    required this.createdDatetime,
    required this.modifiedDatetime,
    required this.subOrganizationId,
    this.employeeName,
    this.closedDate,
    this.lastSettlementDate,
    required this.amountSettled,
    this.referenceNumber,
    this.description,
    this.cashAdvReqId,
    required this.isDuplicated,
    required this.isForged,
    required this.isTobacco,
    required this.isAlcohol,
    this.location,
  });

  factory ExpenseListModel.fromJson(Map<String, dynamic> json) {
    return ExpenseListModel(
      expenseId: json['ExpenseId'] ?? '',
      expenseStatus: json['ExpenseStatus'] ?? '',
      totalAmountTrans: (json['TotalAmountTrans'] ?? 0).toDouble(),
      employeeId: json['EmployeeId'] ?? '',
      receiptDate: _parseTimestamp(json['ReceiptDate']),
      approvalStatus: json['ApprovalStatus'] ?? '',
      currency: json['Currency'] ?? '',
      source: json['Source'] ?? '',
      exchRate: (json['ExchRate'] ?? 1).toDouble(),
      createdBy: json['CreatedBy'] ?? '',
      modifiedBy: json['ModifiedBy'] ?? '',
      organizationId: json['OrganizationId'] ?? 0,
      recId: json['RecId'] ?? 0,
      totalAmountReporting: (json['TotalAmountReporting'] ?? 0).toDouble(),
      projectId: json['ProjectId'],
      fromDate: _parseTimestamp(json['FromDate']),
      toDate: _parseTimestamp(json['ToDate']),
      paymentMethod: json['PaymentMethod'],
      expenseCategoryId: json['ExpenseCategoryId'] ?? '',
      merchantName: json['MerchantName'],
      merchantId: json['MerchantId'],
      totalApprovedAmount: (json['TotalApprovedAmount'] as num?)?.toDouble(),
      totalRejectedAmount: (json['TotalRejectedAmount'] ?? 0).toDouble(),
      userExchRate: (json['UserExchRate'] ?? 1).toDouble(),
      country: json['Country'],
      taxGroup: json['TaxGroup'],
      taxAmount: (json['TaxAmount'] ?? 0).toDouble(),
      expenseType: json['ExpenseType'] ?? '',
      isReimbursable: json['IsReimbursable'] ?? false,
      isBillable: json['IsBillable'] ?? false,
      isPreauthorised: json['IsPreauthorised'] ?? false,
      createdDatetime: json['CreatedDatetime'] ?? 0,
      modifiedDatetime: json['ModifiedDatetime'] ?? 0,
      subOrganizationId: json['SubOrganizationId'] ?? 0,
      employeeName: json['EmployeeName'],
      closedDate: json['ClosedDate'],
      lastSettlementDate: json['LastSettlementDate'],
      amountSettled: (json['AmountSettled'] ?? 0).toDouble(),
      referenceNumber: json['ReferenceNumber'],
      description: json['Description'],
      cashAdvReqId: json['CashAdvReqId'],
      isDuplicated: json['IsDuplicated'] ?? false,
      isForged: json['IsForged'] ?? false,
      isTobacco: json['IsTobacco'] ?? false,
      isAlcohol: json['IsAlcohol'] ?? false,
      location: json['Location'],
    );
  }
}

DateTime? _parseTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is int) {
    // If it's a timestamp in milliseconds:
    return DateTime.fromMillisecondsSinceEpoch(value);
  } else if (value is String) {
    // If string, try parsing
    return DateTime.tryParse(value);
  }
  return null;
}

class StateModels {
  final String code;
  final String name;

  StateModels({required this.code, required this.name});

  factory StateModels.fromJson(Map<String, dynamic> json) {
    return StateModels(
      code: json['StateId'],
      name: json['StateName'],
    );
  }
}

class Language {
  final String code;
  final String name;

  Language({required this.code, required this.name});

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      code: json['LanguageId'],
      name: json['LanguageName'],
    );
  }
}
// class Language {
//   final String name;
//   final String code;

//   Language({required this.name, required this.code});

//   factory Language.fromJson(Map<String, dynamic> json) {
//     return Language(
//       name: json['LanguageName'],
//       code: _mapLanguageIdToCode(json['LanguageId']),
//     );
//   }

//   static String _mapLanguageIdToCode(String id) {
//     switch (id) {
//       case 'LUG-01':
//         return 'en';
//       case 'LUG-02':
//         return 'ar';
//       case 'LUG-03':
//         return 'zh';
//       case 'LUG-04':
//         return 'fr';
//       default:
//         return 'en'; // fallback
//     }
//   }
// }
// models/cash_advance_requisition.dart
class CashAdvanceRequisition {
  final String requisitionId;
  final String employeeId;
  final String employeeName;
  final double totalRequestedAmountInReporting;
  final double totalEstimatedAmountInReporting;
  final String approvalStatus;
  final String businessJustification;
  final String createdBy;
  final String modifiedBy;
  final int organizationId;
  final int recId;
  final int requestDate;
  final double? totalRequestedAmount;
  final double? totalEstimatedAmount;
  final double totalApprovedAmount;
  final double totalRejectedAmount;
  final double amountSettled;
  final String? description;
  final String? expenseCategoryId;
  final String? prefferedPaymentMethod;
  final String?
      percentage; // ← Could be "50%" (string) or 50.0 → check actual API!
  final String? location;
  final int createdDatetime;
  final int modifiedDatetime;
  final int subOrganizationId;
  final String? projectId;
  final String? estimatedCurrency;
  final String? requestedCurrency;
  final String? requestedExchangerate;
  final String? estimatedExchangerate;
  final String referenceId;
  final double amountPaid;
  final double amountPaidReporting;

  CashAdvanceRequisition({
    required this.requisitionId,
    required this.employeeId,
    required this.employeeName,
    required this.totalRequestedAmountInReporting,
    required this.totalEstimatedAmountInReporting,
    required this.approvalStatus,
    required this.businessJustification,
    required this.createdBy,
    required this.modifiedBy,
    required this.organizationId,
    required this.recId,
    required this.requestDate,
    this.totalRequestedAmount,
    this.totalEstimatedAmount,
    required this.totalApprovedAmount,
    required this.totalRejectedAmount,
    required this.amountSettled,
    this.description,
    this.expenseCategoryId,
    this.prefferedPaymentMethod,
    this.percentage,
    this.location,
    required this.createdDatetime,
    required this.modifiedDatetime,
    required this.subOrganizationId,
    this.projectId,
    this.estimatedCurrency,
    this.requestedCurrency,
    this.requestedExchangerate,
    this.estimatedExchangerate,
    required this.referenceId,
    required this.amountPaid,
    required this.amountPaidReporting,
  });

  factory CashAdvanceRequisition.fromJson(Map<String, dynamic> json) {
    return CashAdvanceRequisition(
      requisitionId: json['RequisitionId']?.toString() ?? '',
      employeeId: json['EmployeeId']?.toString() ?? '',
      employeeName: json['EmployeeName']?.toString() ?? '',
      totalRequestedAmountInReporting:
          (json['TotalRequestedAmountInReporting'] ?? 0.0).toDouble(),
      totalEstimatedAmountInReporting:
          (json['TotalEstimatedAmountInReporting'] ?? 0.0).toDouble(),
      approvalStatus: json['ApprovalStatus']?.toString() ?? '',
      businessJustification: json['BusinessJustification']?.toString() ?? '',
      createdBy: json['CreatedBy']?.toString() ?? '',
      modifiedBy: json['ModifiedBy']?.toString() ?? '',
      organizationId: json['OrganizationId'] is String
          ? int.tryParse(json['OrganizationId']) ?? 0
          : (json['OrganizationId'] ?? 0),
      recId: json['RecId'] is String
          ? int.tryParse(json['RecId']) ?? 0
          : (json['RecId'] ?? 0),
      requestDate: json['RequestDate'] is String
          ? int.tryParse(json['RequestDate']) ?? 0
          : (json['RequestDate'] ?? 0),
      totalRequestedAmount: json['TotalRequestedAmount'] == null
          ? null
          : json['TotalRequestedAmount'].toDouble(),
      totalEstimatedAmount: json['TotalEstimatedAmount'] == null
          ? null
          : json['TotalEstimatedAmount'].toDouble(),
      totalApprovedAmount: (json['TotalApprovedAmount'] ?? 0.0).toDouble(),
      totalRejectedAmount: (json['TotalRejectedAmount'] ?? 0.0).toDouble(),
      amountSettled: (json['AmountSettled'] ?? 0.0).toDouble(),
      description: json['Description']?.toString(),
      expenseCategoryId: json['ExpenseCategoryId']?.toString(),
      prefferedPaymentMethod: json['PrefferedPaymentMethod']?.toString(),
      percentage: json['Percentage']?.toString(), // ← Handle safely as String?
      location: json['Location']?.toString(),
      createdDatetime: json['CreatedDatetime'] is String
          ? int.tryParse(json['CreatedDatetime']) ?? 0
          : (json['CreatedDatetime'] ?? 0),
      modifiedDatetime: json['ModifiedDatetime'] is String
          ? int.tryParse(json['ModifiedDatetime']) ?? 0
          : (json['ModifiedDatetime'] ?? 0),
      subOrganizationId: json['SubOrganizationId'] is String
          ? int.tryParse(json['SubOrganizationId']) ?? 0
          : (json['SubOrganizationId'] ?? 0),
      projectId: json['ProjectId']?.toString(),
      estimatedCurrency: json['EstimatedCurrency']?.toString(),
      requestedCurrency: json['RequestedCurrency']?.toString(),
      requestedExchangerate: json['RequestedExchangerate']?.toString(),
      estimatedExchangerate: json['EstimatedExchangerate']?.toString(),
      referenceId: json['ReferenceId']?.toString() ?? '',
      amountPaid: (json['AmountPaid'] ?? 0.0).toDouble(),
      amountPaidReporting: (json['AmountPaidReporting'] ?? 0.0).toDouble(),
    );
  }
}

class MerchantModel {
  final String merchantId;
  final String merchantNames;
  final String? expenseCategoryId;

  MerchantModel({
    required this.merchantId,
    required this.merchantNames,
    this.expenseCategoryId,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    return MerchantModel(
      merchantId: json['MerchantId'] ?? '',
      merchantNames: json['MerchantNames'] ?? '',
      expenseCategoryId: json['ExpenseCategoryId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MerchantId': merchantId,
      'MerchantNames': merchantNames,
      'ExpenseCategoryId': expenseCategoryId,
    };
  }
}

class Locales {
  final String code;
  final String name;

  Locales({required this.code, required this.name});

  factory Locales.fromJson(Map<String, dynamic> json) {
    return Locales(
      code: json['Code'],
      name: json['Name'],
    );
  }
}

class PaymentMethod {
  final String paymentMethodName;
  final String paymentMethodId;

  PaymentMethod({
    required this.paymentMethodName,
    required this.paymentMethodId,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      paymentMethodName: json['PaymentMethodName'] ?? '',
      paymentMethodId: json['PaymentMethodId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "PaymentMethodName": paymentMethodName,
      "PaymentMethodId": paymentMethodId,
    };
  }

  @override
  String toString() =>
      'PaymentMethod(name: $paymentMethodName, id: $paymentMethodId)';
}

class Timezone {
  final String code;
  final String name;
  final String id;

  Timezone({
    required this.code,
    required this.name,
    required this.id,
  });

  factory Timezone.fromJson(Map<String, dynamic> json) {
    return Timezone(
      code: json['TimezoneCode'] ?? '',
      name: json['TimezoneName'] ?? '',
      id: json['TimezoneId'] ?? '',
    );
  }
}

class Currency {
  final String code;
  final String name;
  final String symbol;

  Currency({
    required this.code,
    required this.name,
    required this.symbol,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['CurrencyCode'] as String,
      name: json['CurrencyName'] as String,
      symbol: json['CurrencySymbol'] as String,
    );
  }
}

class Payment {
  final String code;
  final String name;

  Payment({required this.code, required this.name});

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      code: json['PaymentMethodId'],
      name: json['PaymentMethodName'],
    );
  }
}

class Project {
  final String code;
  final String name;
  final bool isNotEmpty; // Mark as final for immutability

  Project({
    required this.code,
    required this.name,
    required this.isNotEmpty,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      code: json['ProjectId'],
      name: json['ProjectName'],
      isNotEmpty: (json['ProjectId'] != null &&
          json['ProjectId'].toString().isNotEmpty),
    );
  }
}

class ExchangeRateResponse {
  final double totalAmount;
  final int baseUnit;
  final double exchangeRate;

  ExchangeRateResponse({
    required this.totalAmount,
    required this.baseUnit,
    required this.exchangeRate,
  });

  factory ExchangeRateResponse.fromJson(Map<String, dynamic> json) {
    return ExchangeRateResponse(
      totalAmount: (json['Total_Amount'] ?? 0).toDouble(),
      baseUnit: (json['BaseUnit'] ?? 0).toInt(),
      exchangeRate: (json['ExchangeRate'] ?? 0).toDouble(),
    );
  }
}

class Unit {
  final String code;
  final String name;

  Unit({required this.code, required this.name});

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      code: json['UomId'],
      name: json['UomName'],
    );
  }
}

class TaxGroupModel {
  final String taxGroupId;
  final String taxGroup;
  final String country;
  final String createdBy;
  final String modifiedBy;
  final int organizationId;
  final int recId;
  final String description;
  final int createdDatetime;
  final int modifiedDatetime;
  final bool isActive;
  final int subOrganizationId;

  TaxGroupModel({
    required this.taxGroupId,
    required this.taxGroup,
    required this.country,
    required this.createdBy,
    required this.modifiedBy,
    required this.organizationId,
    required this.recId,
    required this.description,
    required this.createdDatetime,
    required this.modifiedDatetime,
    required this.isActive,
    required this.subOrganizationId,
  });

  factory TaxGroupModel.fromJson(Map<String, dynamic> json) {
    return TaxGroupModel(
      taxGroupId: json['TaxGroupId'],
      taxGroup: json['TaxGroup'] ?? '',
      country: json['Country'] ?? '',
      createdBy: json['CreatedBy'] ?? '',
      modifiedBy: json['ModifiedBy'] ?? '',
      organizationId: json['OrganizationId'] ?? 0,
      recId: json['RecId'] ?? 0,
      description: json['Description'] ?? '',
      createdDatetime: json['CreatedDatetime'] ?? 0,
      modifiedDatetime: json['ModifiedDatetime'] ?? 0,
      isActive: json['IsActive'] ?? false,
      subOrganizationId: json['SubOrganizationId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TaxGroupId': taxGroupId,
      'TaxGroup': taxGroup,
      'Country': country,
      'CreatedBy': createdBy,
      'ModifiedBy': modifiedBy,
      'OrganizationId': organizationId,
      'RecId': recId,
      'Description': description,
      'CreatedDatetime': createdDatetime,
      'ModifiedDatetime': modifiedDatetime,
      'IsActive': isActive,
      'SubOrganizationId': subOrganizationId,
    };
  }
}

// models/base_expense.dart
class BaseExpense {
  final String expenseId;
  final String projectId;
  final double totalAmountTrans;
  final String currency;
  final String employeeName;
  final String approvalStatus;
  final int workitemrecid;
  final String expenseType;

  BaseExpense({
    required this.expenseId,
    required this.projectId,
    required this.totalAmountTrans,
    required this.currency,
    required this.employeeName,
    required this.approvalStatus,
    required this.workitemrecid,
    required this.expenseType,
  });
}

class GExpense {
  final String expenseId;
  final String expenseStatus;
  final double totalAmountTrans;
  final String employeeId;
  final DateTime? receiptDate;
  final String approvalStatus;
  final String currency;
  final String source;
  final double exchRate;
  final String createdBy;
  final String modifiedBy;
  final int organizationId;
  final int recId;
  final double totalAmountReporting;
  final String projectId;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? paymentMethod;
  final String expenseCategoryId;
  final String merchantName;
  final String merchantId;
  final double totalApprovedAmount;
  final double totalRejectedAmount;
  final double userExchRate;
  final String? country;
  final String? taxGroup;
  final double taxAmount;
  final String expenseType;
  final bool isReimbursable;
  final bool isBillable;
  final bool isPreauthorised;
  final DateTime createdDatetime;
  final DateTime modifiedDatetime;
  final int subOrganizationId;
  final String employeeName;
  final DateTime? closedDate;
  final DateTime? lastSettlementDate;
  final double amountSettled;
  final String referenceNumber;
  final String? description;
  final String cashAdvReqId;
  final bool isDuplicated;
  final bool isForged;
  final bool isTobacco;
  final bool isAlcohol;
  final String location;

  GExpense({
    required this.expenseId,
    required this.expenseStatus,
    required this.totalAmountTrans,
    required this.employeeId,
    required this.receiptDate,
    required this.approvalStatus,
    required this.currency,
    required this.source,
    required this.exchRate,
    required this.createdBy,
    required this.modifiedBy,
    required this.organizationId,
    required this.recId,
    required this.totalAmountReporting,
    required this.projectId,
    required this.fromDate,
    required this.toDate,
    required this.paymentMethod,
    required this.expenseCategoryId,
    required this.merchantName,
    required this.merchantId,
    required this.totalApprovedAmount,
    required this.totalRejectedAmount,
    required this.userExchRate,
    required this.country,
    required this.taxGroup,
    required this.taxAmount,
    required this.expenseType,
    required this.isReimbursable,
    required this.isBillable,
    required this.isPreauthorised,
    required this.createdDatetime,
    required this.modifiedDatetime,
    required this.subOrganizationId,
    required this.employeeName,
    required this.closedDate,
    required this.lastSettlementDate,
    required this.amountSettled,
    required this.referenceNumber,
    required this.description,
    required this.cashAdvReqId,
    required this.isDuplicated,
    required this.isForged,
    required this.isTobacco,
    required this.isAlcohol,
    required this.location,
  });

  factory GExpense.fromJson(Map<String, dynamic> json) {
    return GExpense(
      expenseId: json['ExpenseId'] ?? '',
      expenseStatus: json['ExpenseStatus'] ?? '',
      totalAmountTrans: (json['TotalAmountTrans'] ?? 0).toDouble(),
      employeeId: json['EmployeeId'] ?? '',
      receiptDate: _toDateTime(json['ReceiptDate']),
      approvalStatus: json['ApprovalStatus'] ?? '',
      currency: json['Currency'] ?? '',
      source: json['Source'] ?? '',
      exchRate: (json['ExchRate'] ?? 0).toDouble(),
      createdBy: json['CreatedBy'] ?? '',
      modifiedBy: json['ModifiedBy'] ?? '',
      organizationId: json['OrganizationId'] ?? 0,
      recId: json['RecId'] ?? 0,
      totalAmountReporting: (json['TotalAmountReporting'] ?? 0).toDouble(),
      projectId: json['ProjectId'] ?? '',
      fromDate: _toDateTime(json['FromDate']),
      toDate: _toDateTime(json['ToDate']),
      paymentMethod: json['PaymentMethod'],
      expenseCategoryId: json['ExpenseCategoryId'] ?? '',
      merchantName: json['MerchantName'] ?? '',
      merchantId: json['MerchantId'] ?? '',
      totalApprovedAmount: (json['TotalApprovedAmount'] ?? 0).toDouble(),
      totalRejectedAmount: (json['TotalRejectedAmount'] ?? 0).toDouble(),
      userExchRate: (json['UserExchRate'] ?? 0).toDouble(),
      country: json['Country'],
      taxGroup: json['TaxGroup'],
      taxAmount: (json['TaxAmount'] ?? 0).toDouble(),
      expenseType: json['ExpenseType'] ?? '',
      isReimbursable: json['IsReimbursable'] ?? false,
      isBillable: json['IsBillable'] ?? false,
      isPreauthorised: json['IsPreauthorised'] ?? false,
      createdDatetime: _toDateTime(json['CreatedDatetime']) ?? DateTime.now(),
      modifiedDatetime: _toDateTime(json['ModifiedDatetime']) ?? DateTime.now(),
      subOrganizationId: json['SubOrganizationId'] ?? 0,
      employeeName: json['EmployeeName'] ?? '',
      closedDate: _toDateTime(json['ClosedDate']),
      lastSettlementDate: _toDateTime(json['LastSettlementDate']),
      amountSettled: (json['AmountSettled'] ?? 0).toDouble(),
      referenceNumber: json['ReferenceNumber'] ?? '',
      description: json['Description'],
      cashAdvReqId: json['CashAdvReqId'] ?? '',
      isDuplicated: json['IsDuplicated'] ?? false,
      isForged: json['IsForged'] ?? false,
      isTobacco: json['IsTobacco'] ?? false,
      isAlcohol: json['IsAlcohol'] ?? false,
      location: json['Location'] ?? '',
    );
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    try {
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String) return DateTime.tryParse(value);
    } catch (_) {}
    return null;
  }
}

class PaymentMethodModel {
  final String paymentMethodId;
  final String paymentMethodName;
  final bool reimbursible;

  PaymentMethodModel({
    required this.paymentMethodId,
    required this.paymentMethodName,
    required this.reimbursible,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      paymentMethodId: json['PaymentMethodId'] ?? '',
      paymentMethodName: json['PaymentMethodName'] ?? '',
      reimbursible: json['Reimbursible'] ?? false,
    );
  }
}

class ExpenseCategory {
  final String categoryId;
  final String categoryName;
  final List<dynamic> customFields;
  final String defaultPaymentMethod;
  final String defaultTaxGroup;
  final int expenseCategoriesRecId;
  final String? expenseCategoryIcon;
  final bool itemisationMandatory;
  final double maxExpenseAmount;
  final double minExpensesAmount;
  final double receiptRequiredLimit;

  ExpenseCategory({
    required this.categoryId,
    required this.categoryName,
    required this.customFields,
    required this.defaultPaymentMethod,
    required this.defaultTaxGroup,
    required this.expenseCategoriesRecId,
    this.expenseCategoryIcon,
    required this.itemisationMandatory,
    required this.maxExpenseAmount,
    required this.minExpensesAmount,
    required this.receiptRequiredLimit,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      categoryId: json['CategoryId'] ?? '',
      categoryName: json['CategoryName'] ?? '',
      customFields: json['CustomFields'] ?? [],
      defaultPaymentMethod: json['DefaultPaymentMethod'] ?? '',
      defaultTaxGroup: json['DefaultTaxGroup'] ?? '',
      expenseCategoriesRecId: json['ExpenseCategoriesRecId'] ?? 0,
      expenseCategoryIcon: json['ExpenseCategoryIcon'],
      itemisationMandatory: json['ItemisationMandatory'] ?? false,
      maxExpenseAmount: (json['MaxExpenseAmount'] ?? 0).toDouble(),
      minExpensesAmount: (json['MinExpensesAmount'] ?? 0).toDouble(),
      receiptRequiredLimit: (json['ReceiptRequiredLimit'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CategoryId': categoryId,
      'CategoryName': categoryName,
      'CustomFields': customFields,
      'DefaultPaymentMethod': defaultPaymentMethod,
      'DefaultTaxGroup': defaultTaxGroup,
      'ExpenseCategoriesRecId': expenseCategoriesRecId,
      'ExpenseCategoryIcon': expenseCategoryIcon,
      'ItemisationMandatory': itemisationMandatory,
      'MaxExpenseAmount': maxExpenseAmount,
      'MinExpensesAmount': minExpensesAmount,
      'ReceiptRequiredLimit': receiptRequiredLimit,
    };
  }
}

class MileageRateResponse {
  final String mileageRate;
  final String mileageUnit;
  final String vehicleType;
  final String currency;
  final List<MileageRateLine> mileageRateLines;

  MileageRateResponse({
    required this.mileageRate,
    required this.mileageUnit,
    required this.vehicleType,
    required this.currency,
    required this.mileageRateLines,
  });

  factory MileageRateResponse.fromJson(Map<String, dynamic> json) {
    return MileageRateResponse(
      mileageRate: json['MileageRate'] as String,
      mileageUnit: json['MileageUnit'] as String,
      vehicleType: json['VehicleType'] as String,
      currency: json['Currency'] as String,
      mileageRateLines: (json['MileageRateLines'] as List)
          .map((e) => MileageRateLine.fromJson(e))
          .toList(),
    );
  }
}

class MileageRateLine {
  final double mileageRate;
  final double maximumDistances;
  final double minimumDistances;

  MileageRateLine({
    required this.mileageRate,
    required this.maximumDistances,
    required this.minimumDistances,
  });

  factory MileageRateLine.fromJson(Map<String, dynamic> json) {
    return MileageRateLine(
      mileageRate: (json['MileageRate'] as num).toDouble(),
      maximumDistances: (json['MaximumDistances'] as num).toDouble(),
      minimumDistances: (json['MinimumDistances'] as num).toDouble(),
    );
  }
}

class AccountingDistribution {
  double transAmount;
  double reportAmount;
  String dimensionValueId;
  double allocationFactor;
  // String? currency;
  int? recId; // 👈 optional field

  AccountingDistribution({
    required this.transAmount,
    required this.reportAmount,
    required this.dimensionValueId,
    required this.allocationFactor,
    // this.currency,
    this.recId,
  });

  factory AccountingDistribution.fromJson(Map<String, dynamic> json) {
    return AccountingDistribution(
      transAmount: (json['TransAmount'] ?? 0).toDouble(),
      reportAmount: (json['ReportAmount'] ?? 0).toDouble(),
      dimensionValueId: json['DimensionValueId'] ?? "",
      allocationFactor: (json['AllocationFactor'] ?? 0).toDouble(),
      // currency: json['Currency'],
      recId: json['RecId'], // 👈 safe optional mapping
    );
  }

  /// Example: percentage based on allocation factor (0–1 → 0–100)
  double get percentage => allocationFactor * 100;

  Map<String, dynamic> toJson() {
    return {
      'TransAmount': transAmount,
      'ReportAmount': reportAmount,
      'DimensionValueId': dimensionValueId,
      'AllocationFactor': allocationFactor,
      // 'Currency': currency,
      if (recId != null) 'RecId': recId, // only include if not null
    };
  }

  AccountingDistribution copy() {
    return AccountingDistribution(
      transAmount: transAmount,
      reportAmount: reportAmount,
      dimensionValueId: dimensionValueId,
      allocationFactor: allocationFactor,
      // currency: currency,
      recId: recId,
    );
  }
}

class PerDiemResponseModel {
  final String perdiemId;
  final String currencyCode;
  final int totalDays;
  final double totalAmountTrans;
  final List<AllocationLine> allocationLines;

  PerDiemResponseModel({
    required this.perdiemId,
    required this.currencyCode,
    required this.totalDays,
    required this.totalAmountTrans,
    required this.allocationLines,
  });

  factory PerDiemResponseModel.fromJson(Map<String, dynamic> json) {
    final lines = (json['AllocationLines'] as List? ?? [])
        .map((e) => AllocationLine.fromJson(e))
        .toList();

    return PerDiemResponseModel(
      perdiemId: json['PerdiemId'] ?? '',
      currencyCode: json['Currencycode'] ?? '',
      totalDays: json['Totaldays'] ?? 0,
      totalAmountTrans: (json['TotalAmountTrans'] ?? 0).toDouble(),
      allocationLines: lines,
    );
  }
}

class AllocationLine {
  final String perDiemId;
  final String expenseCategoryId;
  double unitPriceTrans;
  double quantity;
  final int effectiveFrom;
  final int effectiveTo;
  double perDayRate;
  double parsed;
  String? errorText;
  AllocationLine({
    required this.perDiemId,
    required this.expenseCategoryId,
    required this.unitPriceTrans,
    required this.quantity,
    required this.effectiveFrom,
    required this.effectiveTo,
    this.perDayRate = 0.0,
    this.parsed = 0.0,
  });

  /// Convert from JSON
  factory AllocationLine.fromJson(Map<String, dynamic> json) {
    return AllocationLine(
      perDiemId: json['PerDiemId'] ?? '',
      expenseCategoryId: json['ExpenseCategoryId'] ?? '',
      unitPriceTrans: (json['UnitPriceTrans'] ?? 0).toDouble(),
      quantity: (json['Quantity'] ?? 0).toDouble(),
      effectiveFrom: json['EffectiveFrom'] ?? 0,
      effectiveTo: json['EffectiveTo'] ?? 0,
    );
  }

  /// Derived total days from quantity
  int get totalDays => quantity.toInt();

  /// Derived line amount
  double get lineAmountTrans => quantity * unitPriceTrans;

  /// Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      "PerDiemId": perDiemId,
      "ExpenseCategoryId": expenseCategoryId,
      "UnitPriceTrans": unitPriceTrans,
      "Quantity": quantity,
      "EffectiveFrom": effectiveFrom,
      "EffectiveTo": effectiveTo,
      "LineAmountTrans": lineAmountTrans,
      "LineAmountReporting": lineAmountTrans,
    };
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String time;
  final String imageUrl;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.time,
    required this.imageUrl,
    this.isRead = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      time: json['time'],
      imageUrl: json['imageUrl'],
      isRead: json['isRead'] ?? false,
    );
  }
}

class PerdiemResponseModel {
  final String expenseId;
  final String? cashAdvReqId;
  final String? projectId;
  final double totalAmountTrans;
  final double totalAmountReporting;
  final String? merchantName;
  final String? employeeId;
  final String? employeeName;
  final int receiptDate;
  final String? approvalStatus;
  final String? currency;
  final String? referenceNumber;
  final String? source;
  final double exchRate;
  final double userExchRate;
  final bool isBillable;
  final bool isPreauthorised;
  final String? expenseType;
  final String? taxGroup;
  final double taxAmount;
  final bool isReimbursable;
  final String? country;
  final int recId;
  final String? expenseStatus;
  final String? description;
  final String? location;
  final int fromDate;
  final int toDate;
  final int noOfDays;
  final String? stepType;
  final int? workitemrecid;
  final List<dynamic> expenseHeaderCustomFieldValues;
  final List<dynamic> expenseHeaderExpensecategorycustomfieldvalues;
  late List<AccountingDistribution> accountingDistributions;
  final List<AllocationLine> allocationLines;

  PerdiemResponseModel({
    required this.expenseId,
    this.cashAdvReqId,
    this.projectId,
    required this.totalAmountTrans,
    required this.totalAmountReporting,
    this.merchantName,
    this.employeeId,
    this.employeeName,
    required this.receiptDate,
    this.approvalStatus,
    this.currency,
    this.referenceNumber,
    this.source,
    required this.exchRate,
    required this.userExchRate,
    required this.isBillable,
    required this.isPreauthorised,
    this.expenseType,
    this.taxGroup,
    required this.taxAmount,
    required this.isReimbursable,
    this.country,
    required this.recId,
    this.expenseStatus,
    this.description,
    this.location,
    required this.fromDate,
    required this.toDate,
    required this.noOfDays,
    this.stepType,
    this.workitemrecid,
    required this.expenseHeaderCustomFieldValues,
    required this.expenseHeaderExpensecategorycustomfieldvalues,
    required this.accountingDistributions,
    required this.allocationLines,
  });

  factory PerdiemResponseModel.fromJson(Map<String, dynamic> json) {
    return PerdiemResponseModel(
      expenseId: json['ExpenseId'] ?? '',
      cashAdvReqId: json['CashAdvReqId']?.toString(),
      projectId: json['ProjectId']?.toString(),
      totalAmountTrans: (json['TotalAmountTrans'] ?? 0).toDouble(),
      totalAmountReporting: (json['TotalAmountReporting'] ?? 0).toDouble(),
      merchantName: json['MerchantName']?.toString(),
      employeeId: json['EmployeeId']?.toString(),
      employeeName: json['EmployeeName']?.toString(),
      receiptDate: json['ReceiptDate'] ?? 0,
      approvalStatus: json['ApprovalStatus']?.toString(),
      currency: json['Currency']?.toString(),
      referenceNumber: json['ReferenceNumber']?.toString(),
      source: json['Source']?.toString(),
      exchRate: (json['ExchRate'] ?? 1).toDouble(),
      userExchRate:
          double.tryParse(json['UserExchRate']?.toString() ?? '1') ?? 1,
      isBillable: json['IsBillable'] ?? false,
      isPreauthorised: json['IsPreauthorised'] ?? false,
      expenseType: json['ExpenseType']?.toString(),
      taxGroup: json['TaxGroup']?.toString(),
      taxAmount: double.tryParse(json['TaxAmount']?.toString() ?? '0') ?? 0,
      isReimbursable: json['IsReimbursable'] ?? false,
      country: json['Country']?.toString(),
      recId: json['RecId'] ?? 0,
      expenseStatus: json['ExpenseStatus']?.toString(),
      description: json['Description']?.toString(),
      location: json['Location']?.toString(),
      fromDate: json['FromDate'] ?? 0,
      toDate: json['ToDate'] ?? 0,
      noOfDays: json['NoOfDays'] ?? 0,
      stepType: json['StepType']?.toString(),
      workitemrecid: json['workitemrecid'],
      expenseHeaderCustomFieldValues:
          json['ExpenseHeaderCustomFieldValues'] ?? [],
      expenseHeaderExpensecategorycustomfieldvalues:
          json['ExpenseHeaderExpensecategorycustomfieldvalues'] ?? [],
      accountingDistributions: (json['AccountingDistributions'] as List? ?? [])
          .map((e) => AccountingDistribution.fromJson(e))
          .toList(),
      allocationLines: (json['AllocationLines'] as List? ?? [])
          .map((e) => AllocationLine.fromJson(e))
          .toList(),
    );
  }
}

class LocationModel {
  final String location;
  final String description;
  final String createdBy;
  final String modifiedBy;
  final int organizationId;
  final int recId;
  final String region;
  final String country;
  final String city;
  final int createdDatetime;
  final int modifiedDatetime;
  final int subOrganizationId;
  final String state;

  LocationModel({
    required this.location,
    required this.description,
    required this.createdBy,
    required this.modifiedBy,
    required this.organizationId,
    required this.recId,
    required this.region,
    required this.country,
    required this.city,
    required this.createdDatetime,
    required this.modifiedDatetime,
    required this.subOrganizationId,
    required this.state,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      location: json['Location'] ?? '',
      description: json['Description'] ?? '',
      createdBy: json['CreatedBy'] ?? '',
      modifiedBy: json['ModifiedBy'] ?? '',
      organizationId: json['OrganizationId'] ?? 0,
      recId: json['RecId'] ?? 0,
      region: json['Region'] ?? '',
      country: json['Country'] ?? '',
      city: json['City'] ?? '',
      createdDatetime: json['CreatedDatetime'] ?? 0,
      modifiedDatetime: json['ModifiedDatetime'] ?? 0,
      subOrganizationId: json['SubOrganizationId'] ?? 0,
      state: json['State'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Location': location,
      'Description': description,
      'CreatedBy': createdBy,
      'ModifiedBy': modifiedBy,
      'OrganizationId': organizationId,
      'RecId': recId,
      'Region': region,
      'Country': country,
      'City': city,
      'CreatedDatetime': createdDatetime,
      'ModifiedDatetime': modifiedDatetime,
      'SubOrganizationId': subOrganizationId,
      'State': state,
    };
  }
}
class ExpenseHeaderModel {
  final int receiptDate;
  final String expenseId;
  final String employeeId;
  final String employeeName;
  final String? merchantName;
  final String? merchantId;
  final String paymentMethod;
  final String cashAdvReqId;
  final String? location;
  final double totalAmountTrans;
  final double totalAmountReporting;
  final String currency;
  final double exchRate;
  final double userExchRate;
  final String source;
  final bool isBillable;
  final String expenseType;
  final List<dynamic> expenseHeaderCustomFieldValues;
  final DocumentAttachmentModel documentAttachment;
  final List<ExpenseTransModel> expenseTrans;

  ExpenseHeaderModel({
    required this.receiptDate,
    required this.expenseId,
    required this.employeeId,
    required this.employeeName,
    this.merchantName,
    this.merchantId,
    required this.paymentMethod,
    required this.cashAdvReqId,
    this.location,
    required this.totalAmountTrans,
    required this.totalAmountReporting,
    required this.currency,
    required this.exchRate,
    required this.userExchRate,
    required this.source,
    required this.isBillable,
    required this.expenseType,
    required this.expenseHeaderCustomFieldValues,
    required this.documentAttachment,
    required this.expenseTrans,
  });

  Map<String, dynamic> toJson() {
    return {
      "ReceiptDate": receiptDate,
      "ExpenseId": expenseId,
      "EmployeeId": employeeId,
      "EmployeeName": employeeName,
      "MerchantName": merchantName,
      "MerchantId": merchantId,
      "PaymentMethod": paymentMethod,
      "CashAdvReqId": cashAdvReqId,
      "Location": location,
      "TotalAmountTrans": totalAmountTrans,
      "TotalAmountReporting": totalAmountReporting,
      "Currency": currency,
      "ExchRate": exchRate,
      "UserExchRate": userExchRate,
      "Source": source,
      "IsBillable": isBillable,
      "ExpenseType": expenseType,
      "ExpenseHeaderCustomFieldValues": expenseHeaderCustomFieldValues,
      "DocumentAttachment": documentAttachment.toJson(),
      "ExpenseTrans": expenseTrans.map((e) => e.toJson()).toList(),
    };
  }

  
}

class DocumentAttachmentModel {
  final List<dynamic> file;
  DocumentAttachmentModel({required this.file});

  Map<String, dynamic> toJson() => {"File": file};
}

class ExpenseTransModel {
  final int receiptDate;
  final String expenseId;
  final String employeeId;
  final String? merchantName;
  final String? merchantId;
  final String cashAdvReqId;
  final String expenseCategoryId;
  final String paymentMethod;
  final double totalAmountTrans;
  final double totalAmountReporting;
  final bool isReimbursable;
  final String currency;
  final double exchRate;
  final double userExchRate;
  final String description;
  final String source;
  final bool isBillable;
  final String expenseType;
  final List<dynamic> expenseHeaderCustomFieldValues;
  final List<dynamic> expenseHeaderExpensecategorycustomfieldvalues;
  final List<dynamic> documentAttachment;
  final List<dynamic> expenseTrans;
  final List<dynamic> accountingDistributions;
  final String projectId;
  final String taxGroup;
  final double taxAmount;
  final String uomId;
  final double quantity;
  final double unitPriceTrans;
  final double lineAmountTrans;
  final double lineAmountReporting;

  ExpenseTransModel({
    required this.receiptDate,
    required this.expenseId,
    required this.employeeId,
    this.merchantName,
    this.merchantId,
    required this.cashAdvReqId,
    required this.expenseCategoryId,
    required this.paymentMethod,
    required this.totalAmountTrans,
    required this.totalAmountReporting,
    required this.isReimbursable,
    required this.currency,
    required this.exchRate,
    required this.userExchRate,
    required this.description,
    required this.source,
    required this.isBillable,
    required this.expenseType,
    required this.expenseHeaderCustomFieldValues,
    required this.expenseHeaderExpensecategorycustomfieldvalues,
    required this.documentAttachment,
    required this.expenseTrans,
    required this.accountingDistributions,
    required this.projectId,
    required this.taxGroup,
    required this.taxAmount,
    required this.uomId,
    required this.quantity,
    required this.unitPriceTrans,
    required this.lineAmountTrans,
    required this.lineAmountReporting,
  });

  Map<String, dynamic> toJson() {
    return {
      "ReceiptDate": receiptDate,
      "ExpenseId": expenseId,
      "EmployeeId": employeeId,
      "MerchantName": merchantName,
      "MerchantId": merchantId,
      "CashAdvReqId": cashAdvReqId,
      "ExpenseCategoryId": expenseCategoryId,
      "PaymentMethod": paymentMethod,
      "TotalAmountTrans": totalAmountTrans,
      "TotalAmountReporting": totalAmountReporting,
      "IsReimbursable": isReimbursable,
      "Currency": currency,
      "ExchRate": exchRate,
      "UserExchRate": userExchRate,
      "Description": description,
      "Source": source,
      "IsBillable": isBillable,
      "ExpenseType": expenseType,
      "ExpenseHeaderCustomFieldValues": expenseHeaderCustomFieldValues,
      "ExpenseHeaderExpensecategorycustomfieldvalues": expenseHeaderExpensecategorycustomfieldvalues,
      "DocumentAttachment": documentAttachment,
      "ExpenseTrans": expenseTrans,
      "AccountingDistributions": accountingDistributions,
      "ProjectId": projectId,
      "TaxGroup": taxGroup,
      "TaxAmount": taxAmount,
      "UomId": uomId,
      "Quantity": quantity,
      "UnitPriceTrans": unitPriceTrans,
      "LineAmountTrans": lineAmountTrans,
      "LineAmountReporting": lineAmountReporting,
    };
  }
}

class ExpenseItem {
  final int? recId; // ✅ Optional field added
  final String? expenseId;
    final String? expenseCategory;
  final double? discount;
  final String expenseCategoryId;
  final double quantity;
  final String uomId;
  final double unitPriceTrans;
  final double taxAmount;
  final String? taxGroup;
  late final double lineAmountTrans;
  final double lineAmountReporting;
  final String? projectId;
  final String description;
  bool isReimbursable;
  bool isBillable;
  final List<AccountingDistribution> accountingDistributions;

  ExpenseItem({
    this.recId, // ✅ Constructor optional
    this.expenseId,
    this.discount,
     this.expenseCategory,
    required this.expenseCategoryId,
    required this.quantity,
    required this.uomId,
    required this.unitPriceTrans,
    required this.taxAmount,
    required this.taxGroup,
    required this.lineAmountTrans,
    required this.lineAmountReporting,
    required this.projectId,
    required this.description,
    required this.isReimbursable,
    required this.isBillable,
    List<AccountingDistribution>? accountingDistributions,
  }) : accountingDistributions = accountingDistributions ?? [];

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      recId: json['RecId'], // ✅ Parse from JSON if available
      expenseId: json['ExpenseId'],
       discount: (json['Discount'] ?? 0).toDouble(),
      expenseCategory: json['ExpenseCategory']?.toString() ?? '',
      expenseCategoryId: json['ExpenseCategoryId'] ?? '',
      quantity: (json['Quantity'] ?? 0).toDouble(),
      uomId: json['UomId'] ?? '',
      unitPriceTrans: (json['UnitPriceTrans'] ?? 0).toDouble(),
      taxAmount: (json['TaxAmount'] ?? 0).toDouble(),
      taxGroup: json['TaxGroup'],
      lineAmountTrans: (json['LineAmountTrans'] ?? 0).toDouble(),
      lineAmountReporting: (json['LineAmountReporting'] ?? 0).toDouble(),
      projectId: json['ProjectId'],
      description: json['Description'] ?? '',
      isReimbursable: json['IsReimbursable'] ?? false,
      isBillable: json['IsBillable'] ?? false,
      accountingDistributions:
          (json['AccountingDistributions'] as List<dynamic>?)
                  ?.map((e) => AccountingDistribution.fromJson(e))
                  .toList() ??
              [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'ExpenseCategoryId': expenseCategoryId,
      'Quantity': quantity,
      'UomId': uomId,
      'UnitPriceTrans': unitPriceTrans,
      'TaxAmount': taxAmount,
      'TaxGroup': taxGroup,
      'LineAmountTrans': lineAmountTrans,
      'LineAmountReporting': lineAmountReporting,
      'ProjectId': projectId,
      'Description': description,
      'IsReimbursable': isReimbursable,
      'IsBillable': isBillable,
      'ExpenseTransCustomFieldValues': [],
      'ExpenseTransExpensecategorycustomfieldvalues': [],
      'AccountingDistributions':
          accountingDistributions.map((e) => e.toJson()).toList(),
    };

    // 🔑 Only add if not null
    if (recId != null) data['RecId'] = recId;
    if (expenseId != null) data['ExpenseId'] = expenseId;

    return data;
  }
}

class CashAdvanceReqModel {
  final String cashAdvanceReqId;
  final DateTime requestDate;

  CashAdvanceReqModel({
    required this.cashAdvanceReqId,
    required this.requestDate,
  });

  factory CashAdvanceReqModel.fromJson(Map<String, dynamic> json) {
    return CashAdvanceReqModel(
      cashAdvanceReqId: json['CashAdvanceReqId'],
      requestDate: DateTime.fromMillisecondsSinceEpoch(json['RequestDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CashAdvanceReqId': cashAdvanceReqId,
      'RequestDate': requestDate.millisecondsSinceEpoch,
    };
  }
}
class ExpenseTrans {
  final String description;
  final double discount;
  final String expenseCategory;
  final String expenseCategoryId;
  final bool isReimbursable;
  final double lineAmountReporting;
  final double lineAmountTrans;
  final String projectId;
  final int quantity;
  final double taxAmount;
  final String? taxGroup;
  final double unitPriceTrans;
  final String uomId;

  ExpenseTrans({
    required this.description,
    required this.discount,
    required this.expenseCategory,
    required this.expenseCategoryId,
    required this.isReimbursable,
    required this.lineAmountReporting,
    required this.lineAmountTrans,
    required this.projectId,
    required this.quantity,
    required this.taxAmount,
    this.taxGroup,
    required this.unitPriceTrans,
    required this.uomId,
  });

  factory ExpenseTrans.fromJson(Map<String, dynamic> json) {
    return ExpenseTrans(
      description: json['Description']?.toString() ?? '',
      discount: (json['Discount'] ?? 0).toDouble(),
      expenseCategory: json['ExpenseCategory']?.toString() ?? '',
      expenseCategoryId: json['ExpenseCategoryId']?.toString() ?? '',
      isReimbursable: json['IsReimbursable'] ?? false,
      lineAmountReporting: (json['LineAmountReporting'] ?? 0).toDouble(),
      lineAmountTrans: (json['LineAmountTrans'] ?? 0).toDouble(),
      projectId: json['ProjectId']?.toString() ?? '',
      quantity: (json['Quantity'] ?? 0).toInt(),
      taxAmount: (json['TaxAmount'] ?? 0).toDouble(),
      taxGroup: json['TaxGroup']?.toString(),
      unitPriceTrans: (json['UnitPriceTrans'] ?? 0).toDouble(),
      uomId: json['UomId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Description': description,
      'Discount': discount,
      'ExpenseCategory': expenseCategory,
      'ExpenseCategoryId': expenseCategoryId,
      'IsReimbursable': isReimbursable,
      'LineAmountReporting': lineAmountReporting,
      'LineAmountTrans': lineAmountTrans,
      'ProjectId': projectId,
      'Quantity': quantity,
      'TaxAmount': taxAmount,
      'TaxGroup': taxGroup,
      'UnitPriceTrans': unitPriceTrans,
      'UomId': uomId,
    };
  }
}

class ExpenseItemUpdate {
  final int? recId;
  final String expenseCategoryId;
  final double quantity;
  final String uomId;
  final double unitPriceTrans;
  final double taxAmount;
  final String? taxGroup;
  final double lineAmountTrans;
  final double lineAmountReporting;
  final String? projectId;
  final String? description;
  final int? expenseId; // Modified to parse safely
  bool isReimbursable;
  bool isBillable;
  late final List<AccountingDistribution> accountingDistributions;

  ExpenseItemUpdate({
    this.recId,
    required this.expenseCategoryId,
    required this.quantity,
    required this.uomId,
    required this.unitPriceTrans,
    required this.taxAmount,
    this.taxGroup,
    required this.lineAmountTrans,
    required this.lineAmountReporting,
    this.projectId,
    this.description,
    this.expenseId,
    required this.isReimbursable,
    required this.isBillable,
    required this.accountingDistributions,
  });

  factory ExpenseItemUpdate.fromJson(Map<String, dynamic> json) {
    return ExpenseItemUpdate(
      recId: json['RecId'],
      expenseCategoryId: json['ExpenseCategoryId']?.toString() ?? '',
      quantity: (json['Quantity'] ?? 0).toDouble(),
      uomId: json['UomId']?.toString() ?? '',
      unitPriceTrans: (json['UnitPriceTrans'] ?? 0).toDouble(),
      taxAmount: (json['TaxAmount'] ?? 0).toDouble(),
      taxGroup: json['TaxGroup']?.toString(),
      lineAmountTrans: (json['LineAmountTrans'] ?? 0).toDouble(),
      lineAmountReporting: (json['LineAmountReporting'] ?? 0).toDouble(),
      projectId: json['ProjectId']?.toString(),
      description: json['Description']?.toString(),
      expenseId: json['ExpenseId'], // ✅ Fix applied
      isReimbursable: json['IsReimbursable'] ?? false,
      isBillable: json['IsBillable'] ?? false,
      accountingDistributions:
          (json['AccountingDistributions'] as List<dynamic>? ?? [])
              .map((e) => AccountingDistribution.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'RecId': recId,
        'ExpenseCategoryId': expenseCategoryId,
        'Quantity': quantity,
        'UomId': uomId,
        'UnitPriceTrans': unitPriceTrans,
        'TaxAmount': taxAmount,
        'TaxGroup': taxGroup,
        'LineAmountTrans': lineAmountTrans,
        'LineAmountReporting': lineAmountReporting,
        'ProjectId': projectId,
        'Description': description,
        'ExpenseId': expenseId,
        'IsReimbursable': isReimbursable,
        'IsBillable': isBillable,
        'ExpenseTransCustomFieldValues': [],
        'ExpenseTransExpensecategorycustomfieldvalues': [],
        'AccountingDistributions':
            accountingDistributions.map((e) => e.toJson()).toList(),
      };
}

class FilterItem {
  final String id;
  final String label;

  FilterItem({required this.id, required this.label});

  factory FilterItem.fromJson(Map<String, dynamic> json) {
    return FilterItem(
      id: json['id'] as String,
      label: json['label'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
      };

  @override
  String toString() => label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ItemizedExpense {
  String? expenseCategoryId;
  String? uomId;
  String? taxGroup;
  double? taxAmount;
  double? unitPriceTrans;
  double? lineAmountTrans;
  String? projectId;
  String? description;
  bool isReimbursable;

  ItemizedExpense({
    this.expenseCategoryId,
    this.uomId,
    this.taxGroup,
    this.taxAmount,
    this.unitPriceTrans,
    this.lineAmountTrans,
    this.projectId,
    this.description,
    this.isReimbursable = false,
  });
}

class GESpeficExpense {
  final String expenseId;
  final String? projectId;
  final String? paymentMethod;
  final double totalAmountTrans;
  final double totalAmountReporting;
  final String? expenseCategoryId;
  final String? merchantName;
  final String? merchantId;
  final String? employeeId;
  final String? employeeName;
  final DateTime receiptDate;
  final String? approvalStatus;
  final String? currency;
  final String? referenceNumber;
  final String? description;
  final String? source;
  final double exchRate;
  final double userExchRate;
  final bool isBillable;
  final bool isPreauthorised;
  final String? expenseType;
  final String? taxGroup;
  final double taxAmount;
  final bool isReimbursable;
  final String? country;
  final int? recId;
  final String? expenseStatus;
  final String cashAdvReqId;
  final String? location;
  final int? workitemrecid;
  final String? stepType;
   final List<ExpenseItemUpdate> expenseTrans;

  GESpeficExpense({
    required this.expenseId,
    this.projectId,
    this.paymentMethod,
    required this.totalAmountTrans,
    required this.totalAmountReporting,
    this.expenseCategoryId,
    this.merchantName,
    this.merchantId,
    this.employeeId,
    this.employeeName,
    required this.receiptDate,
    this.approvalStatus,
    this.currency,
    this.referenceNumber,
    this.description,
    this.source,
    required this.exchRate,
    required this.userExchRate,
    required this.isBillable,
    required this.isPreauthorised,
    this.expenseType,
    this.taxGroup,
    required this.taxAmount,
    required this.isReimbursable,
    this.country,
    required this.recId,
    this.expenseStatus,
    this.location,
    required this.expenseTrans,
    this.workitemrecid,
    this.stepType,
    required this.cashAdvReqId,
  });

  factory GESpeficExpense.fromJson(Map<String, dynamic> json) {
    return GESpeficExpense(
      expenseId: json['ExpenseId']?.toString() ?? '',
      projectId: json['ProjectId']?.toString(),
      paymentMethod: json['PaymentMethod']?.toString(),
      totalAmountTrans: (json['TotalAmountTrans'] ?? 0).toDouble(),
      totalAmountReporting: (json['TotalAmountReporting'] ?? 0).toDouble(),
      expenseCategoryId: json['ExpenseCategoryId']?.toString(),
      merchantName: json['MerchantName']?.toString(),
      merchantId: json['MerchantId']?.toString(),
      employeeId: json['EmployeeId']?.toString(),
      employeeName: json['EmployeeName']?.toString(),
      receiptDate: json['ReceiptDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['ReceiptDate'])
          : DateTime.now(),
      approvalStatus: json['ApprovalStatus']?.toString(),
      currency: json['Currency']?.toString(),
      referenceNumber: json['ReferenceNumber']?.toString(),
      description: json['Description']?.toString(),
      source: json['Source']?.toString(),
      exchRate: (json['ExchRate'] ?? 0).toDouble(),
      userExchRate: (json['UserExchRate'] ?? 0).toDouble(),
      isBillable: _parseBool(json['IsBillable']),
      isPreauthorised: _parseBool(json['IsPreauthorised']),
      expenseType: json['ExpenseType']?.toString(),
      taxGroup: json['TaxGroup']?.toString(),
      taxAmount: (json['TaxAmount'] ?? 0).toDouble(),
      isReimbursable: _parseBool(json['IsReimbursable']),
      country: json['Country']?.toString(),
      recId: json['RecId'] as int?,
      expenseStatus: json['ExpenseStatus']?.toString(),
      location: json['Location']?.toString(),
      cashAdvReqId: json['CashAdvReqId']?.toString() ?? '',
      workitemrecid: int.tryParse(json['workitemrecid']?.toString() ?? ''),
      stepType: json['StepType']?.toString(),
      expenseTrans: (json['ExpenseTrans'] as List<dynamic>? ?? [])
          .map((e) => ExpenseItemUpdate.fromJson(e))
          .toList(),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return false;
  }
}

class VehicleType {
  final String name;
  final String id;
  final List<MileageRateLine> mileageRateLines;

  VehicleType(
      {required this.name, required this.mileageRateLines, required this.id});

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      name: json['VehicleType'],
      id: json['MileageRate'],
      mileageRateLines: (json['MileageRateLines'] as List)
          .map((e) => MileageRateLine.fromJson(e))
          .toList(),
    );
  }
}

class AccountingSplit {
  double percentage;
  double? amount;
  String? paidFor;

  AccountingSplit({
    required this.percentage,
    this.amount,
    this.paidFor,
  });

  AccountingSplit copyWith({
    double? percentage,
    double? amount,
    String? paidFor,
  }) {
    return AccountingSplit(
      percentage: percentage ?? this.percentage,
      amount: amount ?? this.amount,
      paidFor: paidFor ?? this.paidFor,
    );
  }
}

class ItemizeSection {
  final DateTime receiptDate;
  final String? expenseId;
  final String? merchantName;
  final String? description;
  final double amount;
  final double taxAmount;
  final String? expenseCategoryId;
  final String? projectId;
  final String? taxGroup;

  ItemizeSection({
    required this.receiptDate,
    this.expenseId,
    this.merchantName,
    this.description,
    required this.amount,
    required this.taxAmount,
    this.expenseCategoryId,
    this.projectId,
    this.taxGroup,
  });

  // Convert ItemizeSection to JSON (Map<String, dynamic>)
  Map<String, dynamic> toJson() {
    return {
      'ReceiptDate': receiptDate.millisecondsSinceEpoch,
      'ExpenseId': expenseId ?? "",
      'MerchantName': merchantName ?? "",
      'Description': description ?? "",
      'Amount': amount,
      'TaxAmount': taxAmount,
      'ExpenseCategoryId': expenseCategoryId ?? "Bus",
      'ProjectId': projectId ?? "",
      'TaxGroup': taxGroup,
    };
  }
}

class ExpenseModel {
  final String expenseId;
  final String expenseStatus;
  final double totalAmountTrans;
  final String employeeId;
  final int receiptDate;
  final String approvalStatus;
  final String currency;
  final String source;
  final double exchRate;
  final String createdBy;
  final String modifiedBy;
  final int organizationId;
  final int recId;
  final double totalAmountReporting;
  final String? projectId;
  final String? fromDate;
  final String? toDate;
  final String paymentMethod;
  final String? expenseCategoryId;
  final String merchantName;
  final String? merchantId;
  final double? totalApprovedAmount;
  final double totalRejectedAmount;
  final double userExchRate;
  final String? country;
  final String? taxGroup;
  final double taxAmount;
  final String expenseType;
  final bool isReimbursable;
  final bool isBillable;
  final bool isPreauthorised;
  final int createdDatetime;
  final int modifiedDatetime;
  final int subOrganizationId;
  final String employeeName;
  final String? closedDate;
  final String? lastSettlementDate;
  final double amountSettled;
  final String? referenceNumber;
  final String? description;
  final String cashAdvReqId;
  final bool isDuplicated;
  final bool isForged;
  final bool isTobacco;
  final bool isAlcohol;
  final String location;
  final int workitemrecid;
  final String stepType;

  ExpenseModel({
    required this.expenseId,
    required this.expenseStatus,
    required this.totalAmountTrans,
    required this.employeeId,
    required this.receiptDate,
    required this.approvalStatus,
    required this.currency,
    required this.source,
    required this.exchRate,
    required this.createdBy,
    required this.modifiedBy,
    required this.organizationId,
    required this.recId,
    required this.totalAmountReporting,
    this.projectId,
    this.fromDate,
    this.toDate,
    required this.paymentMethod,
    this.expenseCategoryId,
    required this.merchantName,
    this.merchantId,
    this.totalApprovedAmount,
    required this.totalRejectedAmount,
    required this.userExchRate,
    this.country,
    this.taxGroup,
    required this.taxAmount,
    required this.expenseType,
    required this.isReimbursable,
    required this.isBillable,
    required this.isPreauthorised,
    required this.createdDatetime,
    required this.modifiedDatetime,
    required this.subOrganizationId,
    required this.employeeName,
    this.closedDate,
    this.lastSettlementDate,
    required this.amountSettled,
    this.referenceNumber,
    this.description,
    required this.cashAdvReqId,
    required this.isDuplicated,
    required this.isForged,
    required this.isTobacco,
    required this.isAlcohol,
    required this.location,
    required this.workitemrecid,
    required this.stepType,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      expenseId: json['ExpenseId'] ?? '',
      expenseStatus: json['ExpenseStatus'] ?? '',
      totalAmountTrans: (json['TotalAmountTrans'] ?? 0).toDouble(),
      employeeId: json['EmployeeId'] ?? '',
      receiptDate: json['ReceiptDate'] ?? 0,
      approvalStatus: json['ApprovalStatus'] ?? '',
      currency: json['Currency'] ?? '',
      source: json['Source'] ?? '',
      exchRate: (json['ExchRate'] ?? 1.0).toDouble(),
      createdBy: json['CreatedBy'] ?? '',
      modifiedBy: json['ModifiedBy'] ?? '',
      organizationId: json['OrganizationId'] ?? 0,
      recId: json['RecId'] ?? 0,
      totalAmountReporting: (json['TotalAmountReporting'] ?? 0).toDouble(),
      projectId: json['ProjectId']?.toString(),
      fromDate: json['FromDate']?.toString(),
      toDate: json['ToDate']?.toString(),
      paymentMethod: json['PaymentMethod'] ?? '',
      expenseCategoryId: json['ExpenseCategoryId']?.toString(),
      merchantName: json['MerchantName'] ?? '',
      merchantId: json['MerchantId']?.toString(),
      totalApprovedAmount: (json['TotalApprovedAmount'] ?? 0).toDouble(),
      totalRejectedAmount: (json['TotalRejectedAmount'] ?? 0).toDouble(),
      userExchRate: (json['UserExchRate'] ?? 1.0).toDouble(),
      country: json['Country']?.toString(),
      taxGroup: json['TaxGroup']?.toString(),
      taxAmount: (json['TaxAmount'] ?? 0).toDouble(),
      expenseType: json['ExpenseType'] ?? '',
      isReimbursable: json['IsReimbursable'] ?? false,
      isBillable: json['IsBillable'] ?? false,
      isPreauthorised: json['IsPreauthorised'] ?? false,
      createdDatetime: json['CreatedDatetime'] ?? 0,
      modifiedDatetime: json['ModifiedDatetime'] ?? 0,
      subOrganizationId: json['SubOrganizationId'] ?? 0,
      employeeName: json['EmployeeName'] ?? '',
      closedDate: json['ClosedDate']?.toString(),
      lastSettlementDate: json['LastSettlementDate']?.toString(),
      amountSettled: (json['AmountSettled'] ?? 0).toDouble(),
      referenceNumber: json['ReferenceNumber']?.toString(),
      description: json['Description']?.toString(),
      cashAdvReqId: json['CashAdvReqId'] ?? '',
      isDuplicated: json['IsDuplicated'] ?? false,
      isForged: json['IsForged'] ?? false,
      isTobacco: json['IsTobacco'] ?? false,
      isAlcohol: json['IsAlcohol'] ?? false,
      location: json['Location'] ?? '',
      workitemrecid: json['workitemrecid'] ?? 0,
      stepType: json['StepType'] ?? '',
    );
  }
}

class ExpenseHistory {
  final String eventType;
  final String notes;
  final String userName;
  final DateTime createdDate;

  ExpenseHistory({
    required this.eventType,
    required this.notes,
    required this.userName,
    required this.createdDate,
  });

  factory ExpenseHistory.fromJson(Map<String, dynamic> json) {
    // final createdDateMillis = json['CreatedDatetime'];
    return ExpenseHistory(
      eventType: json['EventType'] ?? '',
      notes: json['Notes'] ?? '',
      userName: json['UserName'] ?? '',
      createdDate: () {
        final raw = json['CreatedDatetime'];
        if (raw == null) return DateTime.now();
        if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
        if (raw is String) return DateTime.parse(raw);
        return DateTime.now();
      }(),
// / fallback if missing
    );
  }
}

class PaidForModel {
  final String valueName;
  final String dimensionValueId;

  PaidForModel({required this.valueName, required this.dimensionValueId});

  factory PaidForModel.fromJson(Map<String, dynamic> json) {
    return PaidForModel(
      valueName: json['ValueName'] ?? '',
      dimensionValueId: json['DimensionValueId'] ?? '',
    );
  }
}

class GESpeficExpenseTrans {
  final int recId;
  final int expenseId;
  final String expenseCategoryId;
  final double quantity;
  final String uomId;
  final double unitPriceTrans;
  final double taxAmount;
  final String taxGroup;
  final double lineAmountTrans;
  final double lineAmountReporting;
  final String projectId;
  final String description;
  bool isReimbursable;
  bool isBillable;

  GESpeficExpenseTrans({
    required this.recId,
    required this.expenseId,
    required this.expenseCategoryId,
    required this.quantity,
    required this.uomId,
    required this.unitPriceTrans,
    required this.taxAmount,
    required this.taxGroup,
    required this.lineAmountTrans,
    required this.lineAmountReporting,
    required this.projectId,
    required this.description,
    required this.isReimbursable,
    required this.isBillable,
  });

  factory GESpeficExpenseTrans.fromJson(Map<String, dynamic> json) {
    return GESpeficExpenseTrans(
      recId: json['RecId'] ?? 0,
      expenseId: json['ExpenseId'] ?? 0,
      expenseCategoryId: json['ExpenseCategoryId'] ?? '',
      quantity: (json['Quantity'] ?? 0).toDouble(),
      uomId: json['UomId'] ?? '',
      unitPriceTrans: (json['UnitPriceTrans'] ?? 0).toDouble(),
      taxAmount: (json['TaxAmount'] ?? 0).toDouble(),
      taxGroup: json['TaxGroup'],
      lineAmountTrans: (json['LineAmountTrans'] ?? 0).toDouble(),
      lineAmountReporting: (json['LineAmountReporting'] ?? 0).toDouble(),
      projectId: json['ProjectId'] ?? '',
      description: json['Description'] ?? '',
      isReimbursable: json['IsReimbursable'] ?? false,
      isBillable: json['isBillable'] ?? false,
    );
  }
}

double parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0; // fallback
}

class ExpenseModelMileage {
  final String expenseId;
  final String? cashAdvReqId;
  final String projectId;
  final double totalAmountTrans;
  final double totalAmountReporting;
  final String? merchantName;
  final String employeeId;
  final String employeeName;
  final int receiptDate;
  final String approvalStatus;
  final String currency;
  final String currencyCode;
  final String? referenceNumber;
  final String source;
  final double exchRate;
  final double userExchRate;
  final bool isBillable;
  final bool isPreauthorised;
  final String expenseType;
  final String? taxGroup;
  final double taxAmount;
  final bool isReimbursable;
  final String? country;
  final int? recId;
  final String expenseStatus;
  final String? description;
  final String mileageRateId;
  final String? vehicalType;
  final String? stepType;
  final int? workitemRecId;
  final List<dynamic> expenseHeaderCustomFieldValues;
  final List<dynamic> expenseHeaderExpenseCategoryCustomFieldValues;
  final List<TravelPoint> travelPoints;
  final List<dynamic> accountingDistributions;

  ExpenseModelMileage({
    required this.expenseId,
    this.cashAdvReqId,
    required this.projectId,
    required this.totalAmountTrans,
    required this.totalAmountReporting,
    this.merchantName,
    required this.employeeId,
    required this.employeeName,
    required this.receiptDate,
    required this.approvalStatus,
    required this.currency,
    required this.currencyCode,
    this.referenceNumber,
    required this.source,
    required this.exchRate,
    required this.userExchRate,
    required this.isBillable,
    required this.isPreauthorised,
    required this.expenseType,
    this.taxGroup,
    required this.taxAmount,
    required this.isReimbursable,
    this.country,
    required this.recId,
    required this.expenseStatus,
    this.description,
    required this.mileageRateId,
    this.vehicalType,
    this.stepType,
    this.workitemRecId,
    required this.expenseHeaderCustomFieldValues,
    required this.expenseHeaderExpenseCategoryCustomFieldValues,
    required this.travelPoints,
    required this.accountingDistributions,
  });
  factory ExpenseModelMileage.fromJson(Map<String, dynamic> json) {
    final expenseTrans = json['ExpenseTrans'] as Map<String, dynamic>? ?? {};
    final travelPoints = expenseTrans.values.map((v) {
      return TravelPoint.fromJson(v);
    }).toList();

    return ExpenseModelMileage(
      expenseId: json['ExpenseId'] ?? '',
      cashAdvReqId: json['CashAdvReqId'],
      projectId: json['ProjectId'] ?? '',
      totalAmountTrans: parseDouble(json['TotalAmountTrans']),
      totalAmountReporting: parseDouble(json['TotalAmountReporting']),
      merchantName: json['MerchantName'] ?? '',
      employeeId: json['EmployeeId'] ?? '',
      employeeName: json['EmployeeName'] ?? '',
      receiptDate: json['ReceiptDate'] ?? 0,
      approvalStatus: json['ApprovalStatus'] ?? '',
      currency: json['Currency'] ?? '',
      currencyCode: json['CurrencyCode'] ?? '',
      referenceNumber: json['ReferenceNumber'] ?? '',
      source: json['Source'] ?? '',
      exchRate: parseDouble(json['ExchRate']),
      userExchRate: parseDouble(json['UserExchRate']),
      isBillable: json['IsBillable'] ?? false,
      isPreauthorised: json['IsPreauthorised'] ?? false,
      expenseType: json['ExpenseType'] ?? '',
      taxGroup: json['TaxGroup'],
      taxAmount: parseDouble(json['TaxAmount']),
      isReimbursable: json['IsReimbursable'] ?? false,
      country: json['Country'] ?? '',
      recId: json['RecId'] ?? 0,
      expenseStatus: json['ExpenseStatus'] ?? '',
      description: json['Description'],
      mileageRateId: json['MileageRateId'] ?? '',
      vehicalType: json['VehicalType'],
      stepType: json['StepType'] ?? '',
      workitemRecId: json['workitemrecid'] ?? 0,
      expenseHeaderCustomFieldValues:
          json['ExpenseHeaderCustomFieldValues'] ?? [],
      expenseHeaderExpenseCategoryCustomFieldValues:
          json['ExpenseHeaderExpensecategorycustomfieldvalues'] ?? [],
      travelPoints: travelPoints.isNotEmpty ? travelPoints : [],
      accountingDistributions: json['AccountingDistributions'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "ExpenseId": expenseId,
      "CashAdvReqId": cashAdvReqId,
      "ProjectId": projectId,
      "TotalAmountTrans": totalAmountTrans,
      "TotalAmountReporting": totalAmountReporting,
      "MerchantName": merchantName,
      "EmployeeId": employeeId,
      "EmployeeName": employeeName,
      "ReceiptDate": receiptDate,
      "ApprovalStatus": approvalStatus,
      "Currency": currency,
      "CurrencyCode": currencyCode,
      "ReferenceNumber": referenceNumber,
      "Source": source,
      "ExchRate": exchRate,
      "UserExchRate": userExchRate,
      "IsBillable": isBillable,
      "IsPreauthorised": isPreauthorised,
      "ExpenseType": expenseType,
      "TaxGroup": taxGroup,
      "TaxAmount": taxAmount,
      "IsReimbursable": isReimbursable,
      "Country": country,
      "RecId": recId,
      "ExpenseStatus": expenseStatus,
      "Description": description,
      "MileageRateId": mileageRateId,
      "VehicalType": vehicalType,
      "StepType": stepType,
      "workitemrecid": workitemRecId,
      "ExpenseHeaderCustomFieldValues": expenseHeaderCustomFieldValues,
      "ExpenseHeaderExpensecategorycustomfieldvalues":
          expenseHeaderExpenseCategoryCustomFieldValues,
      "ExpenseTrans": {
        for (int i = 0; i < travelPoints.length; i++)
          "$i": travelPoints[i].toJson(),
      },
      "AccountingDistributions": accountingDistributions,
    };
  }
}

class ChartData {
  final String month;
  final double value;
  ChartData(this.month, this.value);
}

class ProjectData {
  final String x;
  final double y;

  ProjectData(this.x, this.y);
}

class ProjectExpense {
  final String x; // Project ID
  final double y; // Expense amount

  ProjectExpense({required this.x, required this.y});

  factory ProjectExpense.fromJson(Map<String, dynamic> json) {
    return ProjectExpense(
      x: json['x'] ?? '',
      y: (json['y'] as num).toDouble(),
    );
  }
}

class ProjectExpensebycategory {
  final String x; // Category name
  final double y; // Expense amount
  final Color color; // 👈 Add color for chart

  ProjectExpensebycategory({
    required this.x,
    required this.y,
    required this.color,
  });

  factory ProjectExpensebycategory.fromJson(Map<String, dynamic> json) {
    return ProjectExpensebycategory(
      x: json['x'] ?? '',
      y: (json['y'] as num).toDouble(),
      color: getRandomMildColor(),
    );
  }
}

Color getRandomMildColor() {
  Random random = Random();
  int red = (random.nextInt(128) + 127);
  int green = (random.nextInt(128) + 127);
  int blue = (random.nextInt(128) + 127);
  return Color.fromARGB(255, red, green, blue);
}

class User {
  final String userId;
  final String userName;

  User({
    required this.userId,
    required this.userName,
  });

  // Factory constructor to create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['UserId'] ?? '',
      userName: json['UserName'] ?? '',
    );
  }
}

class NotificationModel {
  final int organizationId;
  final int subOrganizationId;
  final int recId;
  final String? purpose;
  final String notificationName;
  final String? purposeValue;
  final String notificationType;
  final String notificationMessage;
  final String notificationStatus;
  final String userId;
  final String batchJobStatus;
  final DateTime createdDatetime;
  final String createdBy;
  final DateTime modifiedDatetime;
  final String modifiedBy;
  bool read; // mutable field

  NotificationModel({
    required this.organizationId,
    required this.subOrganizationId,
    required this.recId,
    this.purpose,
    required this.notificationName,
    this.purposeValue,
    required this.notificationType,
    required this.notificationMessage,
    required this.notificationStatus,
    required this.userId,
    required this.batchJobStatus,
    required this.createdDatetime,
    required this.createdBy,
    required this.modifiedDatetime,
    required this.modifiedBy,
    required this.read,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      organizationId: json['OrganizationId'],
      subOrganizationId: json['SubOrganizationId'],
      recId: json['RecId'],
      purpose: json['Purpose'],
      notificationName: json['NotificationName'],
      purposeValue: json['PurposeValue'],
      notificationType: json['NotificationType'],
      notificationMessage: json['NotificationMessage'],
      notificationStatus: json['NotificationStatus'],
      userId: json['UserId'],
      batchJobStatus: json['BatchJobStatus'],
      createdDatetime:
          DateTime.fromMillisecondsSinceEpoch(json['CreatedDatetime']),
      createdBy: json['CreatedBy'],
      modifiedDatetime: DateTime.parse(json['ModifiedDatetime']),
      modifiedBy: json['ModifiedBy'],
      read: json['Read'] ?? false,
    );
  }
}

class ManageExpensesSummary {
  final String status;
  final double amount;

  ManageExpensesSummary({required this.status, required this.amount});
}

class ManageExpensesCard {
  final String status;
  final double amount;
  final int count;

  ManageExpensesCard({
    required this.status,
    required this.amount,
    required this.count,
  });

  @override
  String toString() {
    return '$status → Count: $count, Amount: $amount';
  }
}

class ExpenseAmountByStatus {
  final String status;
  final double amount;
  final int count;

  ExpenseAmountByStatus({
    required this.status,
    required this.amount,
    this.count = 0, // 👈 default
  });

  factory ExpenseAmountByStatus.fromJson(String status, double amount, [int count = 0]) {
    return ExpenseAmountByStatus(
      status: status,
      amount: amount,
      count: count,
    );
  }
}


class PendingCashAdvanceApproval {
  final double amountPaid;
  final double amountPaidReporting;
  final double amountSettled;
  final String approvalStatus;
  final String businessJustification;
  final String createdBy;
  final int createdDatetime;
  final String? description;
  final String employeeId;
  final String employeeName;
  final String? estimatedCurrency;
  final double? estimatedExchangerate;
  final String? expenseCategoryId;
  final String? location;
  final String modifiedBy;
  final int modifiedDatetime;
  final int organizationId;
  final double? percentage;
  final String prefferedPaymentMethod;
  final String? projectId;
  final int recId;
  final String referenceId;
  final int requestDate;
  final String? requestedCurrency;
  final double? requestedExchangerate;
  final String requisitionId;
  final String stepType;
  final int subOrganizationId;
  final double totalApprovedAmount;
  final double? totalEstimatedAmount;
  final double totalEstimatedAmountInReporting;
  final double totalRejectedAmount;
  final double? totalRequestedAmount;
  final double totalRequestedAmountInReporting;
  final int workitemrecid;

  PendingCashAdvanceApproval({
    required this.amountPaid,
    required this.amountPaidReporting,
    required this.amountSettled,
    required this.approvalStatus,
    required this.businessJustification,
    required this.createdBy,
    required this.createdDatetime,
    this.description,
    required this.employeeId,
    required this.employeeName,
    this.estimatedCurrency,
    this.estimatedExchangerate,
    this.expenseCategoryId,
    this.location,
    required this.modifiedBy,
    required this.modifiedDatetime,
    required this.organizationId,
    this.percentage,
    required this.prefferedPaymentMethod,
    this.projectId,
    required this.recId,
    required this.referenceId,
    required this.requestDate,
    this.requestedCurrency,
    this.requestedExchangerate,
    required this.requisitionId,
    required this.stepType,
    required this.subOrganizationId,
    required this.totalApprovedAmount,
    this.totalEstimatedAmount,
    required this.totalEstimatedAmountInReporting,
    required this.totalRejectedAmount,
    this.totalRequestedAmount,
    required this.totalRequestedAmountInReporting,
    required this.workitemrecid,
  });

  factory PendingCashAdvanceApproval.fromJson(Map<String, dynamic> json) {
    return PendingCashAdvanceApproval(
      amountPaid: json['AmountPaid'] ?? 0.0,
      amountPaidReporting: json['AmountPaidReporting'] ?? 0.0,
      amountSettled: json['AmountSettled'] ?? 0.0,
      approvalStatus: json['ApprovalStatus'] ?? '',
      businessJustification: json['BusinessJustification'] ?? '',
      createdBy: json['CreatedBy'] ?? '',
      createdDatetime: json['CreatedDatetime'] ?? 0,
      description: json['Description'],
      employeeId: json['EmployeeId'] ?? '',
      employeeName: json['EmployeeName'] ?? '',
      estimatedCurrency: json['EstimatedCurrency'],
      estimatedExchangerate: (json['EstimatedExchangerate'] ?? 0).toDouble(),
      expenseCategoryId: json['ExpenseCategoryId'],
      location: json['Location'],
      modifiedBy: json['ModifiedBy'] ?? '',
      modifiedDatetime: json['ModifiedDatetime'] ?? 0,
      organizationId: json['OrganizationId'] ?? 0,
      percentage: (json['Percentage'] != null)
          ? (json['Percentage'] as num).toDouble()
          : null,
      prefferedPaymentMethod: json['PrefferedPaymentMethod'] ?? '',
      projectId: json['ProjectId'],
      recId: json['RecId'] ?? 0,
      referenceId: json['ReferenceId'] ?? '',
      requestDate: json['RequestDate'] ?? 0,
      requestedCurrency: json['RequestedCurrency'],
      requestedExchangerate: (json['RequestedExchangerate'] ?? 0).toDouble(),
      requisitionId: json['RequisitionId'] ?? '',
      stepType: json['StepType'] ?? '',
      subOrganizationId: json['SubOrganizationId'] ?? 0,
      totalApprovedAmount: json['TotalApprovedAmount'] ?? 0.0,
      totalEstimatedAmount: (json['TotalEstimatedAmount'] != null)
          ? (json['TotalEstimatedAmount'] as num).toDouble()
          : null,
      totalEstimatedAmountInReporting:
          json['TotalEstimatedAmountInReporting'] ?? 0.0,
      totalRejectedAmount: json['TotalRejectedAmount'] ?? 0.0,
      totalRequestedAmount: (json['TotalRequestedAmount'] != null)
          ? (json['TotalRequestedAmount'] as num).toDouble()
          : null,
      totalRequestedAmountInReporting:
          json['TotalRequestedAmountInReporting'] ?? 0.0,
      workitemrecid: json['workitemrecid'] ?? 0,
    );
  }
}

class TravelPoint {
  final double quantity;
  final String fromLocation;
  final String toLocation;
  final int recId;

  TravelPoint({
    required this.quantity,
    required this.fromLocation,
    required this.toLocation,
    required this.recId,
  });

  factory TravelPoint.fromJson(Map<String, dynamic> json) {
    return TravelPoint(
      quantity: (json['Quantity'] ?? 0).toDouble(),
      fromLocation: json['FromLocation'] ?? '',
      toLocation: json['ToLocation'] ?? '',
      recId: json['RecId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "Quantity": quantity,
      "FromLocation": fromLocation,
      "ToLocation": toLocation,
      "RecId": recId,
    };
  }
}

class DimensionHierarchy {
  final String dimensionId;
  final String dimensionName;

  DimensionHierarchy({
    required this.dimensionId,
    required this.dimensionName,
  });

  factory DimensionHierarchy.fromJson(Map<String, dynamic> json) {
    return DimensionHierarchy(
      dimensionId: json['DimensionId'] ?? '',
      dimensionName: json['DimensionName'] ?? '',
    );
  }
}

class DimensionValue {
  final String dimensionId;
  final String dimensionValueId;
  final String valueName;

  DimensionValue({
    required this.dimensionId,
    required this.dimensionValueId,
    required this.valueName,
  });

  factory DimensionValue.fromJson(Map<String, dynamic> json) {
    return DimensionValue(
      dimensionId: json['DimensionId'] ?? '',
      dimensionValueId: json['DimensionValueId'] ?? '',
      valueName: json['ValueName'] ?? '',
    );
  }
}

class CashAdvanceRequestItemizeFornew {
  List<AccountingDistribution>? accountingDistributions;
  int? baseUnit;
  int? baseUnitRequested;
  BusinessJustification? businessJustification;
  String? businessJustificationHeader;
  String? createdBy;
  int? createdDatetime;
  String? description;
  List<DocumentAttachment>? documentAttachment;
  String? employeeId;
  String? estimatedCurrency;
  double? estimatedExchangerate;
  double? exchRate;
  String? expenseCategoryId;
  double? lineAdvanceRequested;
  double? lineEstimatedAmount;
  double? lineEstimatedAmountInReporting;
  String? lineEstimatedCurrency;
  double? lineEstimatedExchangerate;
  double? lineRequestedAdvanceInReporting;
  String? lineRequestedCurrency;
  double? lineRequestedExchangerate;
  String? location;
  int? maxAllowedPercentage;
  int? percentage;
  PrefferedPaymentMethod? prefferedPaymentMethod;
  String? paymentMethodId;
  String? paymentMethodName;
  bool? isSelected;
  String? projectId;
  int? quantity;
  int? requestDate;

  double? totalEstimatedAmount;
  double? totalEstimatedAmountInReporting;
  double? totalRequestedAmount;
  double? totalRequestedAmountInReporting;
  String? uomId;
  double? unitEstimatedAmount;
  double? userExchRate;
  List<CustomFieldValue>? cshHeaderCategoryCustomFieldValues;
  List<CustomFieldValue>? cshHeaderCustomFieldValues;
  List<dynamic>? cashAdvTrans;
  double? taxAmount;
  bool? isBillable;
  bool? isReimbursable;
  String? taxGroup;

  CashAdvanceRequestItemizeFornew({
    this.accountingDistributions,
    this.baseUnit,
    this.baseUnitRequested,
    this.businessJustification,
    this.businessJustificationHeader,
    this.createdBy,
    this.createdDatetime,
    this.description,
    this.documentAttachment,
    this.employeeId,
    this.estimatedCurrency,
    this.estimatedExchangerate,
    this.exchRate,
    this.expenseCategoryId,
    this.lineAdvanceRequested,
    this.lineEstimatedAmount,
    this.lineEstimatedAmountInReporting,
    this.lineEstimatedCurrency,
    this.lineEstimatedExchangerate,
    this.lineRequestedAdvanceInReporting,
    this.lineRequestedCurrency,
    this.lineRequestedExchangerate,
    this.location,
    this.maxAllowedPercentage,
    this.percentage,
    this.prefferedPaymentMethod,
    this.paymentMethodId,
    this.paymentMethodName,
    this.isSelected,
    this.projectId,
    this.quantity,
    this.requestDate,
    this.totalEstimatedAmount,
    this.totalEstimatedAmountInReporting,
    this.totalRequestedAmount,
    this.totalRequestedAmountInReporting,
    this.uomId,
    this.unitEstimatedAmount,
    this.userExchRate,
    this.cshHeaderCategoryCustomFieldValues,
    this.cshHeaderCustomFieldValues,
    this.cashAdvTrans,
    this.taxAmount,
    this.isBillable,
    this.isReimbursable,
    this.taxGroup,
  });

  factory CashAdvanceRequestItemizeFornew.fromJson(Map<String, dynamic> json) {
    return CashAdvanceRequestItemizeFornew(
      accountingDistributions:
          (json['AccountingDistributions'] as List<dynamic>?)
                  ?.map((e) => AccountingDistribution.fromJson(e))
                  .toList() ??
              [],
      baseUnit: _toIntOrNull(json['BaseUnit']),
      baseUnitRequested: _toIntOrNull(json['BaseunitRequested']),
      businessJustification: json['BusinessJustification'] != null
          ? BusinessJustification.fromJson(json['BusinessJustification'])
          : null,
      businessJustificationHeader: json['BusinessJustificationHeader'] ?? '',
      createdBy: json['CreatedBy'] ?? '',
      createdDatetime: _toIntOrNull(json['CreatedDatetime']),
      description: json['Description'] ?? '',
      documentAttachment: (json['DocumentAttachment'] as List<dynamic>?)
              ?.map((e) => DocumentAttachment.fromJson(e))
              .toList() ??
          [],
      employeeId: json['EmployeeId'] ?? '',
      estimatedCurrency: json['EstimatedCurrency'] ?? '',
      estimatedExchangerate: _toDoubleOrNull(json['EstimatedExchangerate']),
      exchRate: _toDoubleOrNull(json['ExchRate']),
      expenseCategoryId: json['ExpenseCategoryId'] ?? '',
      lineAdvanceRequested: _toDoubleOrNull(json['LineAdvanceRequested']),
      lineEstimatedAmount: _toDoubleOrNull(json['LineEstimatedAmount']),
      lineEstimatedAmountInReporting:
          _toDoubleOrNull(json['LineEstimatedAmountInReporting']),
      lineEstimatedCurrency: json['LineEstimatedCurrency'] ?? '',
      lineEstimatedExchangerate:
          _toDoubleOrNull(json['LineEstimatedExchangerate']),
      lineRequestedAdvanceInReporting:
          _toDoubleOrNull(json['LineRequestedAdvanceInReporting']),
      lineRequestedCurrency: json['LineRequestedCurrency'] ?? '',
      lineRequestedExchangerate:
          _toDoubleOrNull(json['LineRequestedExchangerate']),
      location: json['Location'] ?? '',
      maxAllowedPercentage: _toIntOrNull(json['MaxAllowedPercentage']),
      percentage: _toIntOrNull(json['Percentage']),
      prefferedPaymentMethod: json['PrefferedPaymentMethod'] != null
          ? PrefferedPaymentMethod.fromJson(json['PrefferedPaymentMethod'])
          : null,
      paymentMethodId: json['PaymentMethodId'] ?? '',
      paymentMethodName: json['PaymentMethodName'] ?? '',
      isSelected: json['isSelected'] ?? false,
      projectId: json['ProjectId'] ?? '',
      quantity: _toIntOrNull(json['Quantity']),
      requestDate: _toIntOrNull(json['RequestDate']),
      totalEstimatedAmount: _toDoubleOrNull(json['TotalEstimatedAmount']),
      totalEstimatedAmountInReporting:
          _toDoubleOrNull(json['TotalEstimatedAmountInReporting']),
      totalRequestedAmount: _toDoubleOrNull(json['TotalRequestedAmount']),
      totalRequestedAmountInReporting:
          _toDoubleOrNull(json['TotalRequestedAmountInReporting']),
      uomId: json['UOMId'] ?? '',
      unitEstimatedAmount: _toDoubleOrNull(json['UnitEstimatedAmount']),
      userExchRate: _toDoubleOrNull(json['UserExchRate']),
      cshHeaderCategoryCustomFieldValues:
          (json['CSHHeaderCategoryCustomFieldValues'] as List<dynamic>?)
                  ?.map((e) => CustomFieldValue.fromJson(e))
                  .toList() ??
              [],
      cshHeaderCustomFieldValues:
          (json['CSHHeaderCustomFieldValues'] as List<dynamic>?)
                  ?.map((e) => CustomFieldValue.fromJson(e))
                  .toList() ??
              [],
      cashAdvTrans: json['CashAdvTrans'] ?? [],
      taxAmount: _toDoubleOrNull(json['TaxAmount']),
      isBillable: json['IsBillable'] ?? false,
      isReimbursable: json['IsReimbursable'] ?? false,
      taxGroup: json['TaxGroup'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "CashAdvReqHeader": 220,
      "ExpenseCategoryId": expenseCategoryId ?? '',
      "Quantity": quantity ?? 1,
      "UOMId": uomId ?? '',
      "Percentage": percentage ?? 100,
      "UnitEstimatedAmount": unitEstimatedAmount ?? 0,
      "LineEstimatedCurrency": lineEstimatedCurrency ?? "INR",
      "LineRequestedCurrency": lineRequestedCurrency ?? "INR",
      "Description": description ?? '',
      "ProjectId": projectId ?? '',
      "Location": location ?? '',
      "LineEstimatedAmount": lineEstimatedAmount ?? 0,
      "LineEstimatedAmountInReporting": lineEstimatedAmountInReporting ?? 1,
      "LineAdvanceRequested": lineAdvanceRequested ?? 10,
      "LineRequestedAdvanceInReporting": lineRequestedAdvanceInReporting ?? 1,
      "LineRequestedExchangerate": lineRequestedExchangerate ?? 1,
      "LineEstimatedExchangerate": lineEstimatedExchangerate ?? 1,
      "TaxGroup": taxGroup,
      "MaxAllowedPercentage": maxAllowedPercentage ?? 100,
      "BaseUnit": baseUnit ?? 1,
      "BaseunitRequested": baseUnitRequested ?? 1,
      "CSHTransCustomFieldValues": [],
      "CSHTransCategoryCustomFieldValues": [],
      "AccountingDistributions":
          accountingDistributions?.map((e) => e.toJson()).toList() ?? [],
      if (businessJustification != null)
        "BusinessJustification": businessJustification!.toJson(),
      if (prefferedPaymentMethod != null)
        "PrefferedPaymentMethod": prefferedPaymentMethod!.toJson(),
      if (documentAttachment != null)
        "DocumentAttachment":
            documentAttachment!.map((e) => e.toJson()).toList(),
    };
  }

  /// Helper to safely convert numbers
  static double? _toDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString());
  }

  static int? _toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class CashAdvanceRequestItemize {
  List<AccountingDistribution>? accountingDistributions;
  int? baseUnit;
  int? baseUnitRequested;
  BusinessJustification? businessJustification;
  String? businessJustificationHeader;
  String? createdBy;
  int? createdDatetime;
  String? description;
  List<DocumentAttachment>? documentAttachment;
  String? employeeId;
  String? estimatedCurrency;
  double? estimatedExchangerate;
  double? exchRate;
  String? expenseCategoryId;
  double? lineAdvanceRequested;
  double? lineEstimatedAmount;
  double? lineEstimatedAmountInReporting;
  String? lineEstimatedCurrency;
  double? lineEstimatedExchangerate;
  double? lineRequestedAdvanceInReporting;
  String? lineRequestedCurrency;
  double? lineRequestedExchangerate;
  String? location;
  int? maxAllowedPercentage;
  int? percentage;
  PrefferedPaymentMethod? prefferedPaymentMethod;
  String? paymentMethodId;
  String? paymentMethodName;
  bool? isSelected;
  String? projectId;
  int? quantity;
  int? requestDate;
  int? recId;

  /// 🔹 Newly added
  int? cashAdvReqHeader;

  double? totalEstimatedAmount;
  double? totalEstimatedAmountInReporting;
  double? totalRequestedAmount;
  double? totalRequestedAmountInReporting;
  String? uomId;
  double? unitEstimatedAmount;
  double? userExchRate;
  List<CustomFieldValue>? cshHeaderCategoryCustomFieldValues;
  List<CustomFieldValue>? cshHeaderCustomFieldValues;
  List<dynamic>? cashAdvTrans;
  double? taxAmount;

  CashAdvanceRequestItemize({
    this.recId,
    this.cashAdvReqHeader, // 🔹 Added in constructor
    this.accountingDistributions,
    this.baseUnit,
    this.baseUnitRequested,
    this.businessJustification,
    this.businessJustificationHeader,
    this.createdBy,
    this.createdDatetime,
    this.description,
    this.documentAttachment,
    this.employeeId,
    this.estimatedCurrency,
    this.estimatedExchangerate,
    this.exchRate,
    this.expenseCategoryId,
    this.lineAdvanceRequested,
    this.lineEstimatedAmount,
    this.lineEstimatedAmountInReporting,
    this.lineEstimatedCurrency,
    this.lineEstimatedExchangerate,
    this.lineRequestedAdvanceInReporting,
    this.lineRequestedCurrency,
    this.lineRequestedExchangerate,
    this.location,
    this.maxAllowedPercentage,
    this.percentage,
    this.prefferedPaymentMethod,
    this.paymentMethodId,
    this.paymentMethodName,
    this.isSelected,
    this.projectId,
    this.quantity,
    this.requestDate,
    this.totalEstimatedAmount,
    this.totalEstimatedAmountInReporting,
    this.totalRequestedAmount,
    this.totalRequestedAmountInReporting,
    this.uomId,
    this.unitEstimatedAmount,
    this.userExchRate,
    this.cshHeaderCategoryCustomFieldValues,
    this.cshHeaderCustomFieldValues,
    this.cashAdvTrans,
    this.taxAmount,
  });

  factory CashAdvanceRequestItemize.fromJson(Map<String, dynamic> json) {
    return CashAdvanceRequestItemize(
      accountingDistributions:
          (json['AccountingDistributions'] as List<dynamic>?)
                  ?.map((e) => AccountingDistribution.fromJson(e))
                  .toList() ??
              [],
      recId: _toIntOrNull(json['RecId']),
      cashAdvReqHeader: _toIntOrNull(json['CashAdvReqHeader']), // 🔹 Added
      baseUnit: _toIntOrNull(json['BaseUnit']),
      baseUnitRequested: _toIntOrNull(json['BaseunitRequested']),
      businessJustification: json['BusinessJustification'] != null
          ? BusinessJustification.fromJson(json['BusinessJustification'])
          : null,
      businessJustificationHeader: json['BusinessJustificationHeader'] ?? '',
      createdBy: json['CreatedBy'] ?? '',
      createdDatetime: _toIntOrNull(json['CreatedDatetime']),
      description: json['Description'] ?? '',
      documentAttachment: (json['DocumentAttachment'] as List<dynamic>?)
              ?.map((e) => DocumentAttachment.fromJson(e))
              .toList() ??
          [],
      employeeId: json['EmployeeId'] ?? '',
      estimatedCurrency: json['EstimatedCurrency'] ?? '',
      estimatedExchangerate: _toDoubleOrNull(json['EstimatedExchangerate']),
      exchRate: _toDoubleOrNull(json['ExchRate']),
      expenseCategoryId: json['ExpenseCategoryId'] ?? '',
      lineAdvanceRequested: _toDoubleOrNull(json['LineAdvanceRequested']),
      lineEstimatedAmount: _toDoubleOrNull(json['LineEstimatedAmount']),
      lineEstimatedAmountInReporting:
          _toDoubleOrNull(json['LineEstimatedAmountInReporting']),
      lineEstimatedCurrency: json['LineEstimatedCurrency'] ?? '',
      lineEstimatedExchangerate:
          _toDoubleOrNull(json['LineEstimatedExchangerate']),
      lineRequestedAdvanceInReporting:
          _toDoubleOrNull(json['LineRequestedAdvanceInReporting']),
      lineRequestedCurrency: json['LineRequestedCurrency'] ?? '',
      lineRequestedExchangerate:
          _toDoubleOrNull(json['LineRequestedExchangerate']),
      location: json['Location'] ?? '',
      maxAllowedPercentage: _toIntOrNull(json['MaxAllowedPercentage']),
      percentage: _toIntOrNull(json['Percentage']),
      prefferedPaymentMethod: json['PrefferedPaymentMethod'] != null
          ? PrefferedPaymentMethod.fromJson(json['PrefferedPaymentMethod'])
          : null,
      paymentMethodId: json['PaymentMethodId'] ?? '',
      paymentMethodName: json['PaymentMethodName'] ?? '',
      isSelected: json['isSelected'] ?? false,
      projectId: json['ProjectId'] ?? '',
      quantity: _toIntOrNull(json['Quantity']),
      requestDate: _toIntOrNull(json['RequestDate']),
      totalEstimatedAmount: _toDoubleOrNull(json['TotalEstimatedAmount']),
      totalEstimatedAmountInReporting:
          _toDoubleOrNull(json['TotalEstimatedAmountInReporting']),
      totalRequestedAmount: _toDoubleOrNull(json['TotalRequestedAmount']),
      totalRequestedAmountInReporting:
          _toDoubleOrNull(json['TotalRequestedAmountInReporting']),
      uomId: json['UOMId'] ?? '',
      unitEstimatedAmount: _toDoubleOrNull(json['UnitEstimatedAmount']),
      userExchRate: _toDoubleOrNull(json['UserExchRate']),
      cshHeaderCategoryCustomFieldValues:
          (json['CSHHeaderCategoryCustomFieldValues'] as List<dynamic>?)
                  ?.map((e) => CustomFieldValue.fromJson(e))
                  .toList() ??
              [],
      cshHeaderCustomFieldValues:
          (json['CSHHeaderCustomFieldValues'] as List<dynamic>?)
                  ?.map((e) => CustomFieldValue.fromJson(e))
                  .toList() ??
              [],
      cashAdvTrans: json['CashAdvTrans'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "RecId": recId,
      "CashAdvReqHeader": cashAdvReqHeader, // 🔹 Added
      "ExpenseCategoryId": expenseCategoryId ?? '',
      "Quantity": quantity ?? 1,
      "UOMId": uomId ?? '',
      "Percentage": percentage ?? 100,
      "UnitEstimatedAmount": unitEstimatedAmount ?? 0,
      "LineEstimatedCurrency": lineEstimatedCurrency ?? "INR",
      "LineRequestedCurrency": lineRequestedCurrency ?? "INR",
      "Description": description ?? '',
      "ProjectId": projectId ?? '',
      "Location": location ?? '',
      "LineEstimatedAmount": lineEstimatedAmount ?? 0,
      "LineEstimatedAmountInReporting": lineEstimatedAmountInReporting ?? 1,
      "LineAdvanceRequested": lineAdvanceRequested ?? 10,
      "LineRequestedAdvanceInReporting": lineRequestedAdvanceInReporting ?? 1,
      "LineRequestedExchangerate": lineRequestedExchangerate ?? 1,
      "LineEstimatedExchangerate": lineEstimatedExchangerate ?? 1,
      "MaxAllowedPercentage": maxAllowedPercentage ?? 100,
      "BaseUnit": baseUnit ?? 1,
      "BaseunitRequested": baseUnitRequested ?? 1,
      "CSHTransCustomFieldValues": [],
      "CSHTransCategoryCustomFieldValues": [],
      "AccountingDistributions":
          accountingDistributions?.map((e) => e.toJson()).toList() ?? [],
      if (businessJustification != null)
        "BusinessJustification": businessJustification!.toJson(),
      if (prefferedPaymentMethod != null)
        "PrefferedPaymentMethod": prefferedPaymentMethod!.toJson(),
      if (documentAttachment != null)
        "DocumentAttachment":
            documentAttachment!.map((e) => e.toJson()).toList(),
    };
  }

  /// Helper to safely convert numbers
  static double? _toDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString());
  }

  static int? _toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class SequenceNumber {
  final String module;
  final String area;
  final String? nextNumber;

  SequenceNumber({required this.module, required this.area, this.nextNumber});

  factory SequenceNumber.fromJson(Map<String, dynamic> json) {
    return SequenceNumber(
      module: json['Module'],
      area: json['Area'],
      nextNumber: json['NextNumber'],
    );
  }
}

class DocumentAttachment {
  String fileName;
  String fileType;
  String fileUrl;
  int uploadedDatetime;
  String uploadedBy;

  DocumentAttachment({
    required this.fileName,
    required this.fileType,
    required this.fileUrl,
    required this.uploadedDatetime,
    required this.uploadedBy,
  });

  factory DocumentAttachment.fromJson(Map<String, dynamic> json) {
    return DocumentAttachment(
      fileName: json['FileName'] ?? '',
      fileType: json['FileType'] ?? '',
      fileUrl: json['FileUrl'] ?? '',
      uploadedDatetime: json['UploadedDatetime'] ?? 0,
      uploadedBy: json['UploadedBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "FileName": fileName,
      "FileType": fileType,
      "FileUrl": fileUrl,
      "UploadedDatetime": uploadedDatetime,
      "UploadedBy": uploadedBy,
    };
  }
}

class PrefferedPaymentMethod {
  String paymentMethodName;
  String paymentMethodId;
  bool isSelected;

  PrefferedPaymentMethod({
    required this.paymentMethodName,
    required this.paymentMethodId,
    required this.isSelected,
  });

  factory PrefferedPaymentMethod.fromJson(Map<String, dynamic> json) {
    return PrefferedPaymentMethod(
      paymentMethodName: json['PaymentMethodName'] ?? '',
      paymentMethodId: json['PaymentMethodId'] ?? '',
      isSelected: json['isSelected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "PaymentMethodName": paymentMethodName,
      "PaymentMethodId": paymentMethodId,
      "isSelected": isSelected,
    };
  }
}

class CustomFieldValue {
  String customFieldEntity;
  String fieldId;
  String fieldValue;
  String fieldName;

  CustomFieldValue({
    required this.customFieldEntity,
    required this.fieldId,
    required this.fieldValue,
    required this.fieldName,
  });

  Map<String, dynamic> toJson() => {
        "CustomFieldEntity": customFieldEntity,
        "FieldId": fieldId,
        "FieldValue": fieldValue,
        "FieldName": fieldName,
      };

  factory CustomFieldValue.fromJson(Map<String, dynamic> json) {
    return CustomFieldValue(
      customFieldEntity: json['CustomFieldEntity'] ?? '',
      fieldId: json['FieldId'] ?? '',
      fieldValue: json['FieldValue'] ?? '',
      fieldName: json['FieldName'] ?? '',
    );
  }
}

class BusinessJustification {
  String id;
  String name;
  String applicability;
  String description;

  BusinessJustification({
    required this.id,
    required this.name,
    required this.applicability,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Name": name,
        "Applicability": applicability,
        "Description": description,
      };

  factory BusinessJustification.fromJson(Map<String, dynamic> json) {
    return BusinessJustification(
      id: json['Id'] ?? '',
      name: json['Name'] ?? '',
      applicability: json['Applicability'] ?? '',
      description: json['Description'] ?? '',
    );
  }
}

class CashAdvanceRequestHeader {
  final int recId;
  final String requisitionId;
  final String? projectId;
  final String? prefferedPaymentMethod; // nullable now
  final double totalApprovedAmount;
  final double totalRejectedAmount;
  final String? expenseCategoryId;
  final double? totalRequestedAmount;
  final double totalRequestedAmountInReporting;
  final double? totalEstimatedAmount;
  final double totalEstimatedAmountInReporting;
  final double amountSettled;
  final String employeeId;
  final String employeeName;
  final int requestDate;
  final String approvalStatus;
  final String? estimatedCurrency;
  final String? requestedCurrency;
  final double? requestedExchangerate;
  final double? estimatedExchangerate;
  final double? percentage;
  final String businessJustification;
  final String? referenceId;
  final String? description;
  final String? location;
  final String? stepType;
  final int? workitemrecid;
  final List<dynamic> cshHeaderCustomFieldValues;
  final List<dynamic> cshHeaderCategoryCustomFieldValues;
  final List<CashAdvanceRequestItemize> cshCashAdvReqTrans;

  CashAdvanceRequestHeader({
    required this.recId,
    required this.requisitionId,
    this.projectId,
    this.prefferedPaymentMethod,
    required this.totalApprovedAmount,
    required this.totalRejectedAmount,
    this.expenseCategoryId,
    this.totalRequestedAmount,
    required this.totalRequestedAmountInReporting,
    this.totalEstimatedAmount,
    required this.totalEstimatedAmountInReporting,
    required this.amountSettled,
    required this.employeeId,
    required this.employeeName,
    required this.requestDate,
    required this.approvalStatus,
    this.estimatedCurrency,
    this.requestedCurrency,
    this.requestedExchangerate,
    this.estimatedExchangerate,
    this.percentage,
    required this.businessJustification,
    this.referenceId,
    this.description,
    this.location,
    this.stepType,
    this.workitemrecid,
    required this.cshHeaderCustomFieldValues,
    required this.cshHeaderCategoryCustomFieldValues,
    required this.cshCashAdvReqTrans,
  });

  factory CashAdvanceRequestHeader.fromJson(Map<String, dynamic> json) {
    return CashAdvanceRequestHeader(
      recId: json['RecId'] ?? 0,
      requisitionId: json['RequisitionId'] ?? '',
      projectId: json['ProjectId'],
      prefferedPaymentMethod: json['PrefferedPaymentMethod'],
      totalApprovedAmount: (json['TotalApprovedAmount'] ?? 0).toDouble(),
      totalRejectedAmount: (json['TotalRejectedAmount'] ?? 0).toDouble(),
      expenseCategoryId: json['ExpenseCategoryId'],
      totalRequestedAmount: _toDoubleOrNull(json['TotalRequestedAmount']),
      totalRequestedAmountInReporting:
          (json['TotalRequestedAmountInReporting'] ?? 0).toDouble(),
      totalEstimatedAmount: _toDoubleOrNull(json['TotalEstimatedAmount']),
      totalEstimatedAmountInReporting:
          (json['TotalEstimatedAmountInReporting'] ?? 0).toDouble(),
      amountSettled: (json['AmountSettled'] ?? 0).toDouble(),
      employeeId: json['EmployeeId'] ?? '',
      employeeName: json['EmployeeName'] ?? '',
      requestDate: json['RequestDate'] ?? 0,
      approvalStatus: json['ApprovalStatus'] ?? '',
      estimatedCurrency: json['EstimatedCurrency'],
      requestedCurrency: json['RequestedCurrency'],
      requestedExchangerate: _toDoubleOrNull(json['RequestedExchangerate']),
      estimatedExchangerate: _toDoubleOrNull(json['EstimatedExchangerate']),
      percentage: _toDoubleOrNull(json['Percentage']),
      businessJustification: json['BusinessJustification'] ?? '',
      referenceId: json['ReferenceId'],
      description: json['Description'],
      location: json['Location'],
      stepType: json['StepType'],
      workitemrecid: json['workitemrecid'],
      cshHeaderCustomFieldValues:
          List<dynamic>.from(json['CSHHeaderCustomFieldValues'] ?? []),
      cshHeaderCategoryCustomFieldValues:
          List<dynamic>.from(json['CSHHeaderCategoryCustomFieldValues'] ?? []),
      cshCashAdvReqTrans: (json['CSHCashAdvReqTrans'] as List<dynamic>?)
              ?.map((e) => CashAdvanceRequestItemize.fromJson(e))
              .toList() ??
          [],
    );
  }

  get expenseTrans => null;

  Map<String, dynamic> toJson() {
    return {
      'RecId': recId,
      'RequisitionId': requisitionId,
      'ProjectId': projectId,
      'PrefferedPaymentMethod': prefferedPaymentMethod,
      'TotalApprovedAmount': totalApprovedAmount,
      'TotalRejectedAmount': totalRejectedAmount,
      'ExpenseCategoryId': expenseCategoryId,
      'TotalRequestedAmount': totalRequestedAmount,
      'TotalRequestedAmountInReporting': totalRequestedAmountInReporting,
      'TotalEstimatedAmount': totalEstimatedAmount,
      'TotalEstimatedAmountInReporting': totalEstimatedAmountInReporting,
      'AmountSettled': amountSettled,
      'EmployeeId': employeeId,
      'EmployeeName': employeeName,
      'RequestDate': requestDate,
      'ApprovalStatus': approvalStatus,
      'EstimatedCurrency': estimatedCurrency,
      'RequestedCurrency': requestedCurrency,
      'RequestedExchangerate': requestedExchangerate,
      'EstimatedExchangerate': estimatedExchangerate,
      'Percentage': percentage,
      'BusinessJustification': businessJustification,
      'ReferenceId': referenceId,
      'Description': description,
      'Location': location,
      'StepType': stepType,
      'workitemrecid': workitemrecid,
      'CSHHeaderCustomFieldValues': cshHeaderCustomFieldValues,
      'CSHHeaderCategoryCustomFieldValues': cshHeaderCategoryCustomFieldValues,
      'CSHCashAdvReqTrans': cshCashAdvReqTrans.map((e) => e.toJson()).toList(),
    };
  }
}

class ExpenseRequestHeader {
  final String expenseId;
  final bool isDuplicated;
  final bool isAlcohol;
  final bool isForged;
  final bool isTobacco;
  final String cashAdvReqId;
  final String? projectId;
  final String paymentMethod;
  final double totalAmountTrans;
  final double totalAmountReporting;
  final String expenseCategoryId;
  final String merchantName;
  final String? merchantId;
  final String employeeId;
  final String employeeName;
  final int receiptDate;
  final String approvalStatus;
  final String currency;
  final String referenceNumber;
  final String description;
  final String source;
  final double exchRate;
  final double userExchRate;
  final bool isBillable;
  final bool isPreauthorised;
  final String expenseType;
  final String? taxGroup;
  final double taxAmount;
  final bool isReimbursable;
  final String? country;
  final int recId;
  final String expenseStatus;
  final String location;
  final String? fromDate;
  final String? toDate;
  final List<dynamic> expenseHeaderCustomFieldValues;
  final List<dynamic> expenseHeaderExpenseCategoryCustomFieldValues;
  final List<ExpenseTransaction> expenseTrans;

  ExpenseRequestHeader({
    required this.expenseId,
    required this.isDuplicated,
    required this.isAlcohol,
    required this.isForged,
    required this.isTobacco,
    required this.cashAdvReqId,
    this.projectId,
    required this.paymentMethod,
    required this.totalAmountTrans,
    required this.totalAmountReporting,
    required this.expenseCategoryId,
    required this.merchantName,
    this.merchantId,
    required this.employeeId,
    required this.employeeName,
    required this.receiptDate,
    required this.approvalStatus,
    required this.currency,
    required this.referenceNumber,
    required this.description,
    required this.source,
    required this.exchRate,
    required this.userExchRate,
    required this.isBillable,
    required this.isPreauthorised,
    required this.expenseType,
    this.taxGroup,
    required this.taxAmount,
    required this.isReimbursable,
    this.country,
    required this.recId,
    required this.expenseStatus,
    required this.location,
    this.fromDate,
    this.toDate,
    required this.expenseHeaderCustomFieldValues,
    required this.expenseHeaderExpenseCategoryCustomFieldValues,
    required this.expenseTrans,
  });

  factory ExpenseRequestHeader.fromJson(Map<String, dynamic> json) {
    return ExpenseRequestHeader(
      expenseId: json['ExpenseId'] ?? '',
      isDuplicated: json['IsDuplicated'] ?? false,
      isAlcohol: json['IsAlcohol'] ?? false,
      isForged: json['IsForged'] ?? false,
      isTobacco: json['IsTobacco'] ?? false,
      cashAdvReqId: json['CashAdvReqId'] ?? '',
      projectId: json['ProjectId'],
      paymentMethod: json['PaymentMethod'] ?? '',
      totalAmountTrans: (json['TotalAmountTrans'] ?? 0).toDouble(),
      totalAmountReporting: (json['TotalAmountReporting'] ?? 0).toDouble(),
      expenseCategoryId: json['ExpenseCategoryId'] ?? '',
      merchantName: json['MerchantName'] ?? '',
      merchantId: json['MerchantId'],
      employeeId: json['EmployeeId'] ?? '',
      employeeName: json['EmployeeName'] ?? '',
      receiptDate: json['ReceiptDate'] ?? 0,
      approvalStatus: json['ApprovalStatus'] ?? '',
      currency: json['Currency'] ?? '',
      referenceNumber: json['ReferenceNumber'] ?? '',
      description: json['Description'] ?? '',
      source: json['Source'] ?? '',
      exchRate: (json['ExchRate'] ?? 0).toDouble(),
      userExchRate: (json['UserExchRate'] ?? 0).toDouble(),
      isBillable: json['IsBillable'] ?? false,
      isPreauthorised: json['IsPreauthorised'] ?? false,
      expenseType: json['ExpenseType'] ?? '',
      taxGroup: json['TaxGroup'],
      taxAmount: (json['TaxAmount'] ?? 0).toDouble(),
      isReimbursable: json['IsReimbursable'] ?? false,
      country: json['Country'],
      recId: json['RecId'] ?? 0,
      expenseStatus: json['ExpenseStatus'] ?? '',
      location: json['Location'] ?? '',
      fromDate: json['FromDate'],
      toDate: json['ToDate'],
      expenseHeaderCustomFieldValues:
          List<dynamic>.from(json['ExpenseHeaderCustomFieldValues'] ?? []),
      expenseHeaderExpenseCategoryCustomFieldValues: List<dynamic>.from(
          json['ExpenseHeaderExpensecategorycustomfieldvalues'] ?? []),
      expenseTrans: (json['ExpenseTrans'] as List<dynamic>? ?? [])
          .map((e) => ExpenseTransaction.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ExpenseId': expenseId,
      'IsDuplicated': isDuplicated,
      'IsAlcohol': isAlcohol,
      'IsForged': isForged,
      'IsTobacco': isTobacco,
      'CashAdvReqId': cashAdvReqId,
      'ProjectId': projectId,
      'PaymentMethod': paymentMethod,
      'TotalAmountTrans': totalAmountTrans,
      'TotalAmountReporting': totalAmountReporting,
      'ExpenseCategoryId': expenseCategoryId,
      'MerchantName': merchantName,
      'MerchantId': merchantId,
      'EmployeeId': employeeId,
      'EmployeeName': employeeName,
      'ReceiptDate': receiptDate,
      'ApprovalStatus': approvalStatus,
      'Currency': currency,
      'ReferenceNumber': referenceNumber,
      'Description': description,
      'Source': source,
      'ExchRate': exchRate,
      'UserExchRate': userExchRate,
      'IsBillable': isBillable,
      'IsPreauthorised': isPreauthorised,
      'ExpenseType': expenseType,
      'TaxGroup': taxGroup,
      'TaxAmount': taxAmount,
      'IsReimbursable': isReimbursable,
      'Country': country,
      'RecId': recId,
      'ExpenseStatus': expenseStatus,
      'Location': location,
      'FromDate': fromDate,
      'ToDate': toDate,
      'ExpenseHeaderCustomFieldValues': expenseHeaderCustomFieldValues,
      'ExpenseHeaderExpensecategorycustomfieldvalues':
          expenseHeaderExpenseCategoryCustomFieldValues,
      'ExpenseTrans': expenseTrans.map((e) => e.toJson()).toList(),
    };
  }
}

class ExpenseTransaction {
  final int recId;
  final int expenseId;
  final String expenseCategoryId;
  final double quantity;
  final String uomId;
  final double unitPriceTrans;
  final double taxAmount;
  final String? taxGroup;
  final double lineAmountTrans;
  final double lineAmountReporting;
  final String? projectId;
  final String description;
  final bool isReimbursable;
  final List<dynamic> expenseTransCustomFieldValues;
  final List<dynamic> expenseTransExpenseCategoryCustomFieldValues;
  final List<dynamic> accountingDistributions;

  ExpenseTransaction({
    required this.recId,
    required this.expenseId,
    required this.expenseCategoryId,
    required this.quantity,
    required this.uomId,
    required this.unitPriceTrans,
    required this.taxAmount,
    this.taxGroup,
    required this.lineAmountTrans,
    required this.lineAmountReporting,
    this.projectId,
    required this.description,
    required this.isReimbursable,
    required this.expenseTransCustomFieldValues,
    required this.expenseTransExpenseCategoryCustomFieldValues,
    required this.accountingDistributions,
  });

  factory ExpenseTransaction.fromJson(Map<String, dynamic> json) {
    return ExpenseTransaction(
      recId: json['RecId'] ?? 0,
      expenseId: json['ExpenseId'] ?? 0,
      expenseCategoryId: json['ExpenseCategoryId'] ?? '',
      quantity: (json['Quantity'] ?? 0).toDouble(),
      uomId: json['UomId'] ?? '',
      unitPriceTrans: (json['UnitPriceTrans'] ?? 0).toDouble(),
      taxAmount: (json['TaxAmount'] ?? 0).toDouble(),
      taxGroup: json['TaxGroup'],
      lineAmountTrans: (json['LineAmountTrans'] ?? 0).toDouble(),
      lineAmountReporting: (json['LineAmountReporting'] ?? 0).toDouble(),
      projectId: json['ProjectId'],
      description: json['Description'] ?? '',
      isReimbursable: json['IsReimbursable'] ?? false,
      expenseTransCustomFieldValues:
          List<dynamic>.from(json['ExpenseTransCustomFieldValues'] ?? []),
      expenseTransExpenseCategoryCustomFieldValues: List<dynamic>.from(
          json['ExpenseTransExpensecategorycustomfieldvalues'] ?? []),
      accountingDistributions:
          List<dynamic>.from(json['AccountingDistributions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RecId': recId,
      'ExpenseId': expenseId,
      'ExpenseCategoryId': expenseCategoryId,
      'Quantity': quantity,
      'UomId': uomId,
      'UnitPriceTrans': unitPriceTrans,
      'TaxAmount': taxAmount,
      'TaxGroup': taxGroup,
      'LineAmountTrans': lineAmountTrans,
      'LineAmountReporting': lineAmountReporting,
      'ProjectId': projectId,
      'Description': description,
      'IsReimbursable': isReimbursable,
      'ExpenseTransCustomFieldValues': expenseTransCustomFieldValues,
      'ExpenseTransExpensecategorycustomfieldvalues':
          expenseTransExpenseCategoryCustomFieldValues,
      'AccountingDistributions': accountingDistributions,
    };
  }
}

double? _toDoubleOrNull(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

class CashAdvanceGeneralSettings {
  final bool allowCashAdvAgainstExpenseReg;
  final bool allowDocAttachments;
  final bool allowMultipleCashAdvancesPerExpenseReg;
  final bool allowMultipleExpenseSettlementsPerCashAdv;
  final bool enableAutoCashAdvanceSettlement;
  final bool isApprovalRequired;
  final bool isDocAttachmentMandatory;
  final int organizationId;
  final int recId;
  final int subOrganizationId;

  CashAdvanceGeneralSettings({
    required this.allowCashAdvAgainstExpenseReg,
    required this.allowDocAttachments,
    required this.allowMultipleCashAdvancesPerExpenseReg,
    required this.allowMultipleExpenseSettlementsPerCashAdv,
    required this.enableAutoCashAdvanceSettlement,
    required this.isApprovalRequired,
    required this.isDocAttachmentMandatory,
    required this.organizationId,
    required this.recId,
    required this.subOrganizationId,
  });

  factory CashAdvanceGeneralSettings.fromJson(Map<String, dynamic> json) {
    return CashAdvanceGeneralSettings(
      allowCashAdvAgainstExpenseReg:
          json['AllowCashAdvAgainstExpenseReg'] ?? false,
      allowDocAttachments: json['AllowDocAttachments'] ?? false,
      allowMultipleCashAdvancesPerExpenseReg:
          json['AllowMultipleCashAdvancesPerExpenseReg'] ?? false,
      allowMultipleExpenseSettlementsPerCashAdv:
          json['AllowMultipleExpenseSettlementsPerCashAdv'] ?? false,
      enableAutoCashAdvanceSettlement:
          json['EnableAutoCashAdvanceSettlement'] ?? false,
      isApprovalRequired: json['IsApprovalRequired'] ?? false,
      isDocAttachmentMandatory: json['IsDocAttachmentMandatory'] ?? false,
      organizationId: json['OrganizationId'] ?? 0,
      recId: json['RecId'] ?? 0,
      subOrganizationId: json['SubOrganizationId'] ?? 0,
    );
  }
}

class CashAdvanceDropDownModel {
  final String cashAdvanceReqId;
  final int requestDate;

  CashAdvanceDropDownModel({
    required this.cashAdvanceReqId,
    required this.requestDate,
  });

  factory CashAdvanceDropDownModel.fromJson(Map<String, dynamic> json) {
    return CashAdvanceDropDownModel(
      cashAdvanceReqId: json['CashAdvanceReqId'] ?? '',
      requestDate: json['RequestDate'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'CashAdvanceReqId': cashAdvanceReqId,
        'RequestDate': requestDate,
      };
}

class Report {
  String reportName;
  String functionalArea;
  String dataSet;
  String description;
  String applicableFor;
  List<FilterRule> filterRules;
  List<String> selectedFields;

  Report({
    required this.reportName,
    required this.functionalArea,
    required this.dataSet,
    required this.description,
    required this.applicableFor,
    required this.filterRules,
    required this.selectedFields,
  });
}

class FilterRule {
  String table;
  String column;
  String condition;
  dynamic value;

  List<String> inBetweenValues;
  List<String> availableColumns;
  List<String> conditionItems;

  FilterRule({
    required this.table,
    required this.column,
    required this.condition,
    this.value,
    this.inBetweenValues = const [],
    this.availableColumns = const [],
    this.conditionItems = const [],
  });

  Map<String, dynamic> toJson() => {
        'table': table,
        'column': column,
        'condition': condition,
        'value': value,
        'inBetweenValues': inBetweenValues,
        'availableColumns': availableColumns,
        'conditionItems': conditionItems,
      };
}

class Users {
  final String userId;
  final String userName;
  bool selected = false;

  Users({required this.userId, required this.userName});

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      userId: json['UserId'],
      userName: json['UserName'],
    );
  }
}

class EmailHubModel {
  final int recId;
  final int refRecId;
  final String name;
  final String forwardedEmail;
  final String emailBody;
  final String subject;
  final String emailStatus;
  final DateTime forwardedDate;
  final bool isActive;
  final String createdBy;
  final DateTime createdDatetime;
  final String modifiedBy;
  final DateTime modifiedDatetime;
  final int organizationId;
  final int subOrganizationId;

  EmailHubModel({
    required this.recId,
    required this.refRecId,
    required this.name,
    required this.forwardedEmail,
    required this.emailBody,
    required this.subject,
    required this.emailStatus,
    required this.forwardedDate,
    required this.isActive,
    required this.createdBy,
    required this.createdDatetime,
    required this.modifiedBy,
    required this.modifiedDatetime,
    required this.organizationId,
    required this.subOrganizationId,
  });

  factory EmailHubModel.fromJson(Map<String, dynamic> json) {
    return EmailHubModel(
      recId: json['RecId'] ?? 0,
      refRecId: json['RefRecId'] ?? 0,
      name: json['Name'] ?? '',
      forwardedEmail: json['ForwardedEmail'] ?? '',
      emailBody: json['EmailBody'] ?? '',
      subject: json['Subject'] ?? '',
      emailStatus: json['EmailStatus'] ?? '',
      forwardedDate: _fromEpoch(json['ForwardedDate']),
      isActive: json['IsActive'] ?? false,
      createdBy: json['CreatedBy'] ?? '',
      createdDatetime: _fromEpoch(json['CreatedDatetime']),
      modifiedBy: json['ModifiedBy'] ?? '',
      modifiedDatetime: _fromEpoch(json['ModifiedDatetime']),
      organizationId: json['OrganizationId'] ?? 0,
      subOrganizationId: json['SubOrganizationId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RecId': recId,
      'RefRecId': refRecId,
      'Name': name,
      'ForwardedEmail': forwardedEmail,
      'EmailBody': emailBody,
      'Subject': subject,
      'EmailStatus': emailStatus,
      'ForwardedDate': forwardedDate.millisecondsSinceEpoch,
      'IsActive': isActive,
      'CreatedBy': createdBy,
      'CreatedDatetime': createdDatetime.millisecondsSinceEpoch,
      'ModifiedBy': modifiedBy,
      'ModifiedDatetime': modifiedDatetime.millisecondsSinceEpoch,
      'OrganizationId': organizationId,
      'SubOrganizationId': subOrganizationId,
    };
  }

  static DateTime _fromEpoch(dynamic value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      return DateTime.tryParse(value) ?? DateTime(1970);
    }
    return DateTime(1970);
  }
}

class ForwardedEmail {
  final int recId;
  final String name;
  final int forwardedDate;
  final String forwardedEmail;
  final String subject;
  final String emailStatus;
  final int refRecId;
  final String emailBody;
  final bool isActive;
  final List<MailAttachment> documentAttachments;

  ForwardedEmail({
    required this.recId,
    required this.name,
    required this.forwardedDate,
    required this.forwardedEmail,
    required this.subject,
    required this.emailStatus,
    required this.refRecId,
    required this.emailBody,
    required this.isActive,
    required this.documentAttachments,
  });

  factory ForwardedEmail.fromJson(Map<String, dynamic> json) {
    return ForwardedEmail(
      recId: json['RecId'],
      name: json['Name'],
      forwardedDate: json['ForwardedDate'],
      forwardedEmail: json['ForwardedEmail'],
      subject: json['Subject'],
      emailStatus: json['EmailStatus'],
      refRecId: json['RefRecId'],
      emailBody: json['EmailBody'],
      isActive: json['IsActive'],
      documentAttachments: (json['DocumentAttachment'] as List)
          .map((e) => MailAttachment.fromJson(e))
          .toList(),
    );
  }
}

class MailAttachment {
  final String name;
  final String type;
  final String fileExtension;
  final String base64Data;

  MailAttachment({
    required this.name,
    required this.type,
    required this.fileExtension,
    required this.base64Data,
  });

  factory MailAttachment.fromJson(Map<String, dynamic> json) {
    return MailAttachment(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      fileExtension: json['FileExtension'] ?? '',
      base64Data: json['base64Data'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "type": type,
      "FileExtension": fileExtension,
      "base64Data": base64Data,
    };
  }
}

class ReportModels {
  final String name;
  final String reportAvailability;
  final String functionalArea;
  final int recId;
  final String? description;
  final int dataSet;
  final String? availableFor;
  final List<ReportMetaData> reportMetaData;
  final List<ColumnChooser> columnChooser;
  final List<Mapping> mappings;

  ReportModels({
    required this.name,
    required this.reportAvailability,
    required this.functionalArea,
    required this.recId,
    this.description,
    required this.dataSet,
    this.availableFor,
    required this.reportMetaData,
    required this.columnChooser,
    required this.mappings,
  });

  factory ReportModels.fromJson(Map<String, dynamic> json) {
    return ReportModels(
      name: json['Name'],
      reportAvailability: json['ReportAvailability'],
      functionalArea: json['FunctionalArea'],
      recId: json['RecId'],
      description: json['Description'],
      dataSet: json['DataSet'],
      availableFor: json['AvailableFor'],
      reportMetaData: (json['ReportMetaData'] as List)
          .map((e) => ReportMetaData.fromJson(e))
          .toList(),
      columnChooser: (json['ColumnChooser'] as List)
          .map((e) => ColumnChooser.fromJson(e))
          .toList(),
      mappings:
          (json['Mappings'] as List).map((e) => Mapping.fromJson(e)).toList(),
    );
  }
}

class ReportMetaData {
  final String matchType; // 'AND' or 'OR'
  final List<Rule> rules;

  ReportMetaData({
    required this.matchType,
    required this.rules,
  });

  // Factory to create from JSON (for response parsing)
  factory ReportMetaData.fromJson(Map<String, dynamic> json) {
    return ReportMetaData(
      matchType: json['matchType'] as String,
      rules: (json['rules'] as List<dynamic>)
          .map((e) => Rule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Method to convert to JSON (for sending in POST body)
  Map<String, dynamic> toJson() {
    return {
      'matchType': matchType,
      'rules': rules.map((e) => e.toJson()).toList(),
    };
  }

  // Optional: Copy with for updates
  ReportMetaData copyWith({
    String? matchType,
    List<Rule>? rules,
  }) {
    return ReportMetaData(
      matchType: matchType ?? this.matchType,
      rules: rules ?? this.rules,
    );
  }

  @override
  String toString() {
    return 'ReportMetaData(matchType: $matchType, rules: $rules)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportMetaData &&
        matchType == other.matchType &&
        rules.length == other.rules.length &&
        rules.every((r) => other.rules.contains(r));
  }

  @override
  int get hashCode => Object.hash(matchType, rules);
}

class Rule {
  /// Table name (e.g., "Employees", "Expenses")
  final String selectedTable;

  /// Field in the table (e.g., "EmployeeId", "Amount")
  final String selectedField;

  /// Condition operator (e.g., "eq", "neq", "between", "contains")
  final String selectedCondition;

  /// Single value input (used for conditions like 'equals', 'greater than')
  final String singleValue;

  /// Range/in-between values (e.g., [from, to]) — used for 'between' condition
  final List<String> inBetweenValues;

  Rule({
    required this.selectedTable,
    required this.selectedField,
    required this.selectedCondition,
    required this.singleValue,
    required this.inBetweenValues,
  });

  // ✅ Factory to create from JSON (API response parsing)
  factory Rule.fromJson(Map<String, dynamic> json) {
    return Rule(
      selectedTable: json['selectedTable'] as String,
      selectedField: json['selectedField'] as String,
      selectedCondition: json['selectedCondition'] as String,
      singleValue: json['singleValue'] as String,
      inBetweenValues:
          (json['inBetweenValues'] as List).map((e) => e as String).toList(),
    );
  }

  // ✅ Convert to JSON (for sending in POST request)
  Map<String, dynamic> toJson() {
    return {
      'selectedTable': selectedTable,
      'selectedField': selectedField,
      'selectedCondition': selectedCondition,
      'singleValue': singleValue,
      'inBetweenValues': inBetweenValues,
    };
  }

  // ✅ Copy with (useful for updating one field immutably)
  Rule copyWith({
    String? selectedTable,
    String? selectedField,
    String? selectedCondition,
    String? singleValue,
    List<String>? inBetweenValues,
  }) {
    return Rule(
      selectedTable: selectedTable ?? this.selectedTable,
      selectedField: selectedField ?? this.selectedField,
      selectedCondition: selectedCondition ?? this.selectedCondition,
      singleValue: singleValue ?? this.singleValue,
      inBetweenValues: inBetweenValues ?? this.inBetweenValues,
    );
  }

  // ✅ Debugging-friendly string
  @override
  String toString() {
    return 'Rule(selectedTable: $selectedTable, selectedField: $selectedField, selectedCondition: $selectedCondition, singleValue: $singleValue, inBetweenValues: $inBetweenValues)';
  }

  // ✅ Equality check
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Rule &&
        selectedTable == other.selectedTable &&
        selectedField == other.selectedField &&
        selectedCondition == other.selectedCondition &&
        singleValue == other.singleValue &&
        inBetweenValues.length == other.inBetweenValues.length &&
        inBetweenValues.every((v) => other.inBetweenValues.contains(v));
  }

  // ✅ Hash code
  @override
  int get hashCode {
    return Object.hash(
      selectedTable,
      selectedField,
      selectedCondition,
      singleValue,
      Object.hashAll(inBetweenValues),
    );
  }
}

class ColumnChooser {
  final Map<String, dynamic>? header;
  final Map<String, dynamic>? lines;

  ColumnChooser({this.header, this.lines});

  factory ColumnChooser.fromJson(Map<String, dynamic> json) {
    return ColumnChooser(
      header: json['header'],
      lines: json['lines'],
    );
  }
}

class ColumnChooserCheckbox {
  final String columnName;
  final String label;
  bool isSelected;

  ColumnChooserCheckbox({
    required this.columnName,
    required this.label,
    this.isSelected = false,
  });
}

class Mapping {
  final String userId;
  final int refRecId;
  final String createdBy;
  final String modifiedBy;
  final int organizationId;
  final int recId;
  final String createdDatetime;
  final String modifiedDatetime;
  final int subOrganizationId;

  Mapping({
    required this.userId,
    required this.refRecId,
    required this.createdBy,
    required this.modifiedBy,
    required this.organizationId,
    required this.recId,
    required this.createdDatetime,
    required this.modifiedDatetime,
    required this.subOrganizationId,
  });

  factory Mapping.fromJson(Map<String, dynamic> json) {
    return Mapping(
      userId: json['UserId'],
      refRecId: json['RefRecId'],
      createdBy: json['CreatedBy'],
      modifiedBy: json['ModifiedBy'],
      organizationId: json['OrganizationId'],
      recId: json['RecId'],
      createdDatetime: json['CreatedDatetime'],
      modifiedDatetime: json['ModifiedDatetime'],
      subOrganizationId: json['SubOrganizationId'],
    );
  }
}

// Model classes
class ExpenseCategoryAI {
  final String category;
  final double totalExpenses;

  ExpenseCategoryAI({required this.category, required this.totalExpenses});

  factory ExpenseCategoryAI.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryAI(
      category: json['Category'] as String,
      totalExpenses: json['TotalExpenses'] as double,
    );
  }
}

class ApiResponse {
  final List<ExpenseCategoryAI> data;
  final String plotData;
  final String answer;

  ApiResponse(
      {required this.data, required this.plotData, required this.answer});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    List<ExpenseCategoryAI> categories = [];
    if (json['data'] != null && json['data']['Category'] != null) {
      for (var item in json['data']['Category']) {
        categories.add(ExpenseCategoryAI.fromJson(item));
      }
    }

    return ApiResponse(
      data: categories,
      plotData: json['plot'] ?? '',
      answer: json['answer'] ?? '',
    );
  }
}
