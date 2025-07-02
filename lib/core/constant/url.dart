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
  static const geconfigureField =
      "$baseURL/api/v1/masters/fieldmanagement/customfields/expensefieldconfigurations?filter_query=STPFieldConfigurations.FunctionalEntity__eq%3DExpenseRequisition&page=1&sort_order=asc&choosen_fields=FieldId%2CFieldName%2CIsEnabled%2CIsMandatory%2CFunctionalArea%2CRecId&lock_id=123&screen_name=expenseconfigure";
  static const defalutPayment =
      "$baseURL/api/v1/masters/taxmanagement/tax/paymentmethods?filter_query=STPPaymentMethods.IsActive__eq%3Dtrue%26STPPaymentMethods.ImportOnly__eq%3Dfalse&page=1&sort_by=PaymentMethodName&sort_order=asc&choosen_fields=PaymentMethodName%2CPaymentMethodId";
  static const timeZoneDropdown =
      "$baseURL/api/v1/global/global/timezones?page=1&sort_by=TimezoneName&sort_order=asc&choosen_fields=TimezoneId%2CTimezoneName%2CTimezoneCode";
  static const locale =
      "$baseURL/api/v1/global/global/locale?page=1&sort_by=Name&sort_order=asc&choosen_fields=Name%2CCode";
  static const updateAddressDetails =
      "$baseURL/api/v1/masters/usersandrolesmgmt/user/userjoin?UserId=";
  static const userPreferencesAPI =
      "$baseURL/api/v1/masters/usersandrolesmgmt/user/usersettings/?UserId=";
  static const getuserPreferencesAPI =
      "$baseURL/api/v1/masters/usersandrolesmgmt/user/usersettings?filter_query=STPUserSettings.UserId%3D";
  static const updateProfilePicture =
      "$baseURL/api/v1/masters/usersandrolesmgmt/user/userprofiles?UserId=";
  static const getProfilePicture =
      "$baseURL/api/v1/masters/usersandrolesmgmt/useruserprofilepictures?UserId=";
  static const deleteProfilePicture =
      "$baseURL/api/v1/masters/usersandrolesmgmt/user/userprofiles?UserId=";
  static const getPaidtoDropdown =
      "$baseURL/api/v1/expenseregistration/expenseregistration/merchants?TransactionDate=1746556200000";
  static const getPaidwithDropdown =
      "$baseURL/api/v1/masters/taxmanagement/tax/paymentmethods?filter_query=STPPaymentMethods.IsActive__eq%3Dtrue%26STPPaymentMethods.ImportOnly__eq%3Dfalse&page=1&sort_by=PaymentMethodName&sort_order=asc&choosen_fields=PaymentMethodName%2CPaymentMethodId%2CReimbursible";
  static const getProjectDropdown =
      "$baseURL/api/v1/expenseregistration/expenseregistration/projectid?EmployeeId=EMP001&TransactionDate=1749493800000";
  static const taxGroup =
      "$baseURL/api/v1/expenseregistration/expenseregistration/taxgroups?filter_query=TAXTaxGroups.IsActive__eq%3Dtrue&page=1&sort_order=asc";
  static const unitDropdown =
      "$baseURL/api/v1/global/global/unitofmeasurements?filter_query=STPUnitOfMeasurements.IsActive__eq%3Dtrue&page=1&sort_order=asc&choosen_fields=UomId%2CUomName";
  static const currencySymbol =
      "$baseURL/api/v1/expenseregistration/expenseregistration/currency?filter_query=STPCompanyCurrencies.IsActive__eq%3Dtrue&page=1&sort_order=asc&choosen_fields=CurrencyCode%2CCurrencyName%2CCurrencySymbol";
  static const expenseCategory =
      "$baseURL/api/v1/expenseregistration/expenseregistration/expensecategory?ProjectId=";
  static const exchangeRate =
      "$baseURL/api/v1/masters/financemgmt/exchmgmt/exchangerates/exchangerateconversion";
  static const saveGenderalExpense =
      "$baseURL/api/v1/expenseregistration/expenseregistration/expenseregistrationscreen?functionalentity=ExpenseRequisition";
  static const getallGeneralExpense =
      "$baseURL/api/v1/expenseregistration/expenseregistration/expenseheader?filter_query=EXPExpenseHeader.CreatedBy__eq%3D";
  static const getSpecificGeneralExpense =
      "$baseURL/api/v1/expenseregistration/expenseregistration/expenseregistration?";
  static const getSpecificPerdiemExpense =
      "$baseURL/api/v1/perdiemregistration/perdiemregistration/perdiemregistration?RecId=";
  static const getTrackingDetails =
      "$baseURL/api/v1/expenseregistration/expenseregistration/expenselog?filter_query=EXPExpenseTransLog.";
  static const getExpensImage =
      "$baseURL/api/v1/expenseregistration/expenseregistration/getdocumentattachments?RecId=";
  static const autoScanExtract =
      "$baseURL/api/v1/expensemgmt/expenseocr/extract";
  static const dimensionValueDropDown =
      "$baseURL/api/v1/masters/financemgmt/dimensions/dimensions/dimensionvalues?page=1&sort_order=asc";
  static const locationDropDown =
      "$baseURL/api/v1/perdiemregistration/perdiemregistration/locations?page=1&sort_order=asc";
  static const perDiemPrefillValue =
      "$baseURL/api/v1/perdiemregistration/perdiemregistration/perdiemrateid?Fromdate=";
  static const perDiemAllocation =
      "$baseURL/api/v1/masters/financemgmt/exchmgmt/exchangerates/exchangerateconversion/";
  static const perDiemFetchRate =
      "$baseURL/api/v1/perdiemregistration/perdiemregistration/perdiemrateid?Fromdate=";
  static const perDiemRegistration =
      "$baseURL/api/v1/perdiemregistration/perdiemregistration/PerdiumRegistration?functionalentity=ExpenseRequisition";
  static const updatetheAllocation =
      "$baseURL/api/v1/masters/financemgmt/exchmgmt/exchangerates/exchangerateconversion/";
  static const deleteExpense=
      "$baseURL/api/v1/expenseregistration/expenseregistration/expenses?RecId=";
}
