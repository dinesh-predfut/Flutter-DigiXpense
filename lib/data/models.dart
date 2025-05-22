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
class Language {
  final String code;
  final String name;

  Language({required this.code, required this.name});

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      code: json['CountryCode'],
      name: json['CountryName'],
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