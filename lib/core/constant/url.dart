class Urls {
  static const String baseURL = "https://api.digixpense.com";
  static const login = "$baseURL/api/v1/tenant/auth/login/";
  static const forgetPassword =
      "$baseURL/api/v1/tenant/auth/forgotpassword/?user_id=";
  static const getPersonalByID =
      "$baseURL/api/v1/masters/usersandrolesmgmt/user/userjoin/";
  static const countryList =
      "$baseURL/api/v1/global/global/countries?sort_order=asc&sort_by=CountryName&choosen_fields=CountryCode%2CCountryName";
  static const stateList =
      "$baseURL/api/v1/global/global/states?filter_query=STPStates.Country__eq%3D";
  static const languageList =
      "$baseURL/api/v1/global/global/globallanguages?page=1&sort_by=LanguageName&sort_order=asc&choosen_fields=LanguageId%2CLanguageName";
  static const correncyDropdown =
      "$baseURL/api/v1/global/globalcurrency/currencyconfigurations?page=1&sort_by=CurrencyName&sort_order=asc&choosen_fields=CurrencyCode%2CCurrencyName%2CCurrencySymbol";
  static const defalutPayment =
      "$baseURL/api/v1/masters/taxmanagement/tax/paymentmethods?filter_query=STPPaymentMethods.IsActive__eq%3Dtrue%26STPPaymentMethods.ImportOnly__eq%3Dfalse&page=1&sort_by=PaymentMethodName&sort_order=asc&choosen_fields=PaymentMethodName%2CPaymentMethodId";
  static const timeZoneDropdown =
      "$baseURL/api/v1/global/global/timezones?page=1&sort_by=TimezoneName&sort_order=asc&choosen_fields=TimezoneId%2CTimezoneName%2CTimezoneCode";
  static const locale =
      "$baseURL/api/v1/global/global/locale?page=1&sort_by=Name&sort_order=asc&choosen_fields=Name%2CCode";
  static const updateAddressDetails =
      "$baseURL/api/v1/masters/usersandrolesmgmt/user/userjoin?UserId=";
       static const userPreferencesAPI=
      "$baseURL/api/v1/masters/usersandrolesmgmt/user/usersettings/?UserId=";
        static const getuserPreferencesAPI=
      "$baseURL/api/v1/masters/usersandrolesmgmt/user/usersettings?filter_query=STPUserSettings.UserId%3D";
        static const updateProfilePicture =
      "$baseURL/api/v1/masters/usersandrolesmgmt/user/userprofiles?UserId=";
}
