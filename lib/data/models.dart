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
      receiptDate: json['ReceiptDate'] ?? 0,
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
      fromDate: json['FromDate'],
      toDate: json['ToDate'],
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
  String? dimensionValueId;
  double allocationFactor;
  String? currency;

  AccountingDistribution({
    required this.transAmount,
    required this.reportAmount,
    this.dimensionValueId,
    required this.allocationFactor,
    this.currency,
  });

  factory AccountingDistribution.fromJson(Map<String, dynamic> json) {
    return AccountingDistribution(
      transAmount: (json['TransAmount'] ?? 0).toDouble(),
      reportAmount: (json['ReportAmount'] ?? 0).toDouble(),
      dimensionValueId: json['DimensionValueId'],
      allocationFactor: (json['AllocationFactor'] ?? 0).toDouble(),
      currency: json['Currency'],
    );
  }

  get percentage => null;

  Map<String, dynamic> toJson() {
    return {
      'TransAmount': transAmount,
      'ReportAmount': reportAmount,
      'DimensionValueId': dimensionValueId,
      'AllocationFactor': allocationFactor,
      'Currency': currency,
    };
  }

  AccountingDistribution copy() {
    return AccountingDistribution(
      transAmount: transAmount,
      reportAmount: reportAmount,
      dimensionValueId: dimensionValueId,
      allocationFactor: allocationFactor,
      currency: currency,
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

class ExpenseItem {
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
  bool isReimbursable;
  bool isBillable;
  final List<AccountingDistribution> accountingDistributions;

  ExpenseItem({
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

  Map<String, dynamic> toJson() => {
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

class ExpenseItemUpdate {
  final String expenseCategoryId;
  final double quantity;
  final String uomId;
  final double unitPriceTrans;
  final double taxAmount;
  final String? taxGroup; // <-- make nullable
  final double lineAmountTrans;
  final double lineAmountReporting;
  final String? projectId;
  final String? description;
  bool isReimbursable;
  bool isBillable;

  late final List<AccountingDistribution> accountingDistributions;

  ExpenseItemUpdate({
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
    required this.isReimbursable,
    required this.isBillable,
    required this.accountingDistributions,
  });

  factory ExpenseItemUpdate.fromJson(Map<String, dynamic> json) {
    return ExpenseItemUpdate(
      expenseCategoryId: json['ExpenseCategoryId'] ?? '',
      quantity: (json['Quantity'] ?? 0).toDouble(),
      uomId: json['UomId'] ?? '',
      unitPriceTrans: (json['UnitPriceTrans'] ?? 0).toDouble(),
      taxAmount: (json['TaxAmount'] ?? 0).toDouble(),
      taxGroup: json['TaxGroup'], // nullable
      lineAmountTrans: (json['LineAmountTrans'] ?? 0).toDouble(),
      lineAmountReporting: (json['LineAmountReporting'] ?? 0).toDouble(),
      projectId: json['ProjectId'],
      description: json['Description'],
      isReimbursable: json['IsReimbursable'] ?? false,
      isBillable: json['IsBillable'] ?? false,
      accountingDistributions:
          (json['AccountingDistributions'] as List<dynamic>? ?? [])
              .map((e) => AccountingDistribution.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
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
  final int recId;
  final String? expenseStatus;
  final String? location;
  final int workitemrecid;
  final String? stepType;
  late final List<ExpenseItemUpdate> expenseTrans;

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
    required this.workitemrecid,
    this.stepType,
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
      isBillable: json['IsBillable'] ?? false,
      isPreauthorised: json['IsPreauthorised'] ?? false,
      expenseType: json['ExpenseType']?.toString(),
      taxGroup: json['TaxGroup']?.toString(),
      taxAmount: (json['TaxAmount'] ?? 0).toDouble(),
      isReimbursable: json['IsReimbursable'] ?? false,
      country: json['Country']?.toString(),
      recId: json['RecId'] ?? 0,
      expenseStatus: json['ExpenseStatus']?.toString(),
      location: json['Location']?.toString(),
      workitemrecid: json['workitemrecid'] ?? 0,
      stepType: json['StepType']?.toString(),
      expenseTrans: (json['ExpenseTrans'] as List<dynamic>? ?? [])
          .map((e) => ExpenseItemUpdate.fromJson(e))
          .toList(),
    );
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
    final createdDateMillis = json['CreatedDatetime'];
    return ExpenseHistory(
      eventType: json['EventType'] ?? '',
      notes: json['Notes'] ?? '',
      userName: json['UserName'] ?? '',
      createdDate: createdDateMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(createdDateMillis)
          : DateTime.now(), // fallback if missing
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

  ManageExpensesCard({required this.status, required this.amount});
}

class ExpenseAmountByStatus {
  final String status; // XAxis label
  final double amount; // YAxis value

  ExpenseAmountByStatus({
    required this.status,
    required this.amount,
  });

  factory ExpenseAmountByStatus.fromJson(String status, double amount) {
    return ExpenseAmountByStatus(
      status: status,
      amount: amount,
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
      percentage: (json['Percentage'] != null) ? (json['Percentage'] as num).toDouble() : null,
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
      totalEstimatedAmount: (json['TotalEstimatedAmount'] != null) ? (json['TotalEstimatedAmount'] as num).toDouble() : null,
      totalEstimatedAmountInReporting: json['TotalEstimatedAmountInReporting'] ?? 0.0,
      totalRejectedAmount: json['TotalRejectedAmount'] ?? 0.0,
      totalRequestedAmount: (json['TotalRequestedAmount'] != null) ? (json['TotalRequestedAmount'] as num).toDouble() : null,
      totalRequestedAmountInReporting: json['TotalRequestedAmountInReporting'] ?? 0.0,
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
      recId: _toIntOrNull(json['RecId'] ?? ''),
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
  final String prefferedPaymentMethod;
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
    required this.prefferedPaymentMethod,
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
      recId: json['RecId'],
      requisitionId: json['RequisitionId'],
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
      employeeId: json['EmployeeId'],
      employeeName: json['EmployeeName'],
      requestDate: json['RequestDate'],
      approvalStatus: json['ApprovalStatus'],
      estimatedCurrency: json['EstimatedCurrency'],
      requestedCurrency: json['RequestedCurrency'],
      requestedExchangerate: _toDoubleOrNull(json['RequestedExchangerate']),
      estimatedExchangerate: _toDoubleOrNull(json['EstimatedExchangerate']),
      percentage: _toDoubleOrNull(json['Percentage']),
      businessJustification: json['BusinessJustification'],
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
      allowCashAdvAgainstExpenseReg: json['AllowCashAdvAgainstExpenseReg'] ?? false,
      allowDocAttachments: json['AllowDocAttachments'] ?? false,
      allowMultipleCashAdvancesPerExpenseReg: json['AllowMultipleCashAdvancesPerExpenseReg'] ?? false,
      allowMultipleExpenseSettlementsPerCashAdv: json['AllowMultipleExpenseSettlementsPerCashAdv'] ?? false,
      enableAutoCashAdvanceSettlement: json['EnableAutoCashAdvanceSettlement'] ?? false,
      isApprovalRequired: json['IsApprovalRequired'] ?? false,
      isDocAttachmentMandatory: json['IsDocAttachmentMandatory'] ?? false,
      organizationId: json['OrganizationId'] ?? 0,
      recId: json['RecId'] ?? 0,
      subOrganizationId: json['SubOrganizationId'] ?? 0,
    );
  }
}
