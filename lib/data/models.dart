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
      taxGroupId: json['TaxGroupId'] ?? '',
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

class AccountingDistribution {
  final double transAmount;
  final double reportAmount;
  final double allocationFactor;
  final String dimensionValueId;

  AccountingDistribution({
    required this.transAmount,
    required this.reportAmount,
    required this.allocationFactor,
    required this.dimensionValueId,
  });

  Map<String, dynamic> toJson() => {
        'TransAmount': transAmount,
        'ReportAmount': reportAmount,
        'AllocationFactor': allocationFactor,
        'DimensionValueId': dimensionValueId,
      };
}

class ExpenseItem {
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
  final bool isReimbursable;
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
    required this.accountingDistributions,
  });

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
  final String projectId;
  final String paymentMethod;
  final double totalAmountTrans;
  final double totalAmountReporting;
  final String expenseCategoryId;
  final String merchantName;
  final String merchantId;
  final String employeeId;
  final String employeeName;
  final DateTime receiptDate;
  final String approvalStatus;
  final String currency;
  final String? referenceNumber;
  final String description;
  final String source;
  final double exchRate;
  final double userExchRate;
  final bool isBillable;
  final bool isPreauthorised;
  final String expenseType;
  final String taxGroup;
  final double taxAmount;
  final bool isReimbursable;
  final String? country;
  final int recId;
  final String expenseStatus;
  final String location;
  final List<GESpeficExpenseTrans> expenseTrans;

  GESpeficExpense({
    required this.expenseId,
    required this.projectId,
    required this.paymentMethod,
    required this.totalAmountTrans,
    required this.totalAmountReporting,
    required this.expenseCategoryId,
    required this.merchantName,
    required this.merchantId,
    required this.employeeId,
    required this.employeeName,
    required this.receiptDate,
    required this.approvalStatus,
    required this.currency,
    this.referenceNumber,
    required this.description,
    required this.source,
    required this.exchRate,
    required this.userExchRate,
    required this.isBillable,
    required this.isPreauthorised,
    required this.expenseType,
    required this.taxGroup,
    required this.taxAmount,
    required this.isReimbursable,
    this.country,
    required this.recId,
    required this.expenseStatus,
    required this.location,
    required this.expenseTrans,
  });

  factory GESpeficExpense.fromJson(Map<String, dynamic> json) {
    return GESpeficExpense(
      expenseId: json['ExpenseId'] ?? '',
      projectId: json['ProjectId'] ?? '',
      paymentMethod: json['PaymentMethod'] ?? '',
      totalAmountTrans: (json['TotalAmountTrans'] ?? 0).toDouble(),
      totalAmountReporting: (json['TotalAmountReporting'] ?? 0).toDouble(),
      expenseCategoryId: json['ExpenseCategoryId'] ?? '',
      merchantName: json['MerchantName'] ?? '',
      merchantId: json['MerchantId'] ?? '',
      employeeId: json['EmployeeId'] ?? '',
      employeeName: json['EmployeeName'] ?? '',
      receiptDate: json['ReceiptDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['ReceiptDate'])
          : DateTime.now(),
      approvalStatus: json['ApprovalStatus'] ?? '',
      currency: json['Currency'] ?? '',
      referenceNumber: json['ReferenceNumber'],
      description: json['Description'] ?? '',
      source: json['Source'] ?? '',
      exchRate: (json['ExchRate'] ?? 0).toDouble(),
      userExchRate: (json['UserExchRate'] ?? 0).toDouble(),
      isBillable: json['IsBillable'] ?? false,
      isPreauthorised: json['IsPreauthorised'] ?? false,
      expenseType: json['ExpenseType'] ?? '',
      taxGroup: json['TaxGroup'] ?? '',
      taxAmount: (json['TaxAmount'] ?? 0).toDouble(),
      isReimbursable: json['IsReimbursable'] ?? false,
      country: json['Country'],
      recId: json['RecId'] ?? 0,
      expenseStatus: json['ExpenseStatus'] ?? '',
      location: json['Location'] ?? '',
      expenseTrans: (json['ExpenseTrans'] as List<dynamic>?)
              ?.map((e) => GESpeficExpenseTrans.fromJson(e))
              .toList() ??
          [],
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
      'TaxGroup': taxGroup ?? "",
    };
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
    return ExpenseHistory(
      eventType: json['EventType'],
      notes: json['Notes'],
      userName: json['UserName'],
      createdDate: DateTime.fromMillisecondsSinceEpoch(json['CreatedDatetime']),
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
  final bool isReimbursable;

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
      taxGroup: json['TaxGroup'] ?? '',
      lineAmountTrans: (json['LineAmountTrans'] ?? 0).toDouble(),
      lineAmountReporting: (json['LineAmountReporting'] ?? 0).toDouble(),
      projectId: json['ProjectId'] ?? '',
      description: json['Description'] ?? '',
      isReimbursable: json['IsReimbursable'] ?? false,
    );
  }
}
