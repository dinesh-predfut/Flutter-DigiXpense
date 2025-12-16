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
      static const geconfigureFieldLeave =
      "$baseURL/api/v1/masters/fieldmanagement/customfields/leavefieldconfigurations?filter_query=STPFieldConfigurations.FunctionalEntity__eq%3DLeaveRequisition&page=1&sort_order=asc&choosen_fields=FieldId%2CFieldName%2CIsEnabled%2CIsMandatory%2CFunctionalArea%2CRecId";
  static const geconfigureFieldCashAdvance =
      "$baseURL/api/v1/masters/cashadvancemgmt/cashadvance/cashfieldconfigurations?filter_query=STPFieldConfigurations.FunctionalEntity__eq%3DCashAdvanceRequisition&page=1&sort_order=asc&choosen_fields=FieldId,FieldName,IsEnabled,IsMandatory,FunctionalArea,RecId";
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
      "$baseURL/api/v1/expenseregistration/expenseregistration/merchants?TransactionDate=";
  static const getPaidwithDropdown =
      "$baseURL/api/v1/masters/taxmanagement/tax/paymentmethods?filter_query=STPPaymentMethods.IsActive__eq%3Dtrue%26STPPaymentMethods.ImportOnly__eq%3Dfalse&page=1&sort_by=PaymentMethodName&sort_order=asc&choosen_fields=PaymentMethodName%2CPaymentMethodId%2CReimbursible";
  static const getProjectDropdown =
      "$baseURL/api/v1/expenseregistration/expenseregistration/projectid";
  static const taxGroup =
      "$baseURL/api/v1/expenseregistration/expenseregistration/taxgroups?filter_query=TAXTaxGroups.IsActive__eq%3Dtrue&page=1&sort_order=asc";
  static const unitDropdown =
      "$baseURL/api/v1/global/global/unitofmeasurements?filter_query=STPUnitOfMeasurements.IsActive__eq%3Dtrue&page=1&sort_order=asc&choosen_fields=UomId%2CUomName";
  static const currencySymbol =
      "$baseURL/api/v1/expenseregistration/expenseregistration/currency?filter_query=STPCompanyCurrencies.IsActive__eq%3Dtrue&page=1&sort_order=asc&choosen_fields=CurrencyCode%2CCurrencyName%2CCurrencySymbol";
  static const expenseCategory =
      "$baseURL/api/v1/expenseregistration/expenseregistration/expensecategory?ProjectId=";
  static const exchangeRate =
      "$baseURL/api/v1/masters/financemgmt/exchmgmt/exchangerates/exchangerateconversionfromorg";
  static const saveGenderalExpense =
      "$baseURL/api/v1/expenseregistration/expenseregistration/expenseregistrationscreen?functionalentity=ExpenseRequisition";
  static const cashadvancerequisitions =
      "$baseURL/api/v1/cashadvancerequisition/cashadvanceregistration/returncashadvance?functionalentity=ExpenseRequisition";
  static const getallGeneralExpense =
      "$baseURL/api/v1/expenseregistration/expenseregistration/expenseheader?filter_query=EXPExpenseHeader.CreatedBy__eq%3D";
  static const getallMyteamsGeneralExpense =
      "$baseURL/api/v1/expenseregistration/expenseregistration/myteamexpenses?";
  static const getallMyteamsCashAdvanseRequest =
      "$baseURL/api/v1/cashadvancerequisition/cashadvanceregistration/myteamcashadvances?";
  static const getSpecificGeneralExpense =
      "$baseURL/api/v1/expenseregistration/expenseregistration";
       static const getSpecificUnprocess =
      "$baseURL/api/v1/expenseregistration/expenseregistration/unprocessedexpense?";
  static const getSpecificCashAdvanceApproval =
      "$baseURL/api/v1/masters/approvalmanagement/workflowapproval/detailedapproval?";
       static const getSpecificCashAdvanceteams =
      "$baseURL/api/v1/cashadvancerequisition/cashadvanceregistration/cashadvance?";
  static const getSpecificGeneralExpenseApproval =
      "$baseURL/api/v1/masters/approvalmanagement/workflowapproval/detailedapproval?";
  static const updateApprovalStatus =
      "$baseURL/api/v1/masters/approvalmanagement/workflowapproval/approveraction?functionalentity=ExpenseRequisition";
  static const updateApprovalStatusCashAdvance =
      "$baseURL/api/v1/masters/approvalmanagement/workflowapproval/approveraction?functionalentity=CashAdvanceRequisition";
  static const getSpecificPerdiemExpense =
      "$baseURL/api/v1/perdiemregistration/perdiemregistration/perdiemregistration?RecId=";
  static const getSpecificPerdiemExpenseApproval =
      "$baseURL/api/v1/perdiemregistration/perdiemregistration/detailedapproval?";
  static const getTrackingDetails =
      "$baseURL/api/v1/expenseregistration/expenseregistration/expenselog?filter_query=EXPExpenseTransLog.";
  static const unProcessedList =
      "$baseURL/api/v1/expenseregistration/expenseregistration/unprocessedexpenseheader?filter_query=EXPUnProcessedExpenses.CreatedBy__eq%3D";
  static const cashadvanceTracking =
      "$baseURL/api/v1/cashadvancerequisition/cashadvanceregistration/cashadvancelogs?filter_query=CSHCashAdvTransLog.";
  static const approvalPerdiemreview =
      "$baseURL/api/v1/perdiemregistration/perdiemregistration/reviewperdiemregistration?";
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
  static const deleteExpense =
      "$baseURL/api/v1/expenseregistration/expenseregistration/expenses?RecId=";
      static const deleteExpenseUnprocess =
      "$baseURL/api/v1/expenseregistration/expenseregistration/unprocessedexpense?RecId=";
  static const pendingApprovals =
      "$baseURL/api/v1/masters/approvalmanagement/workflowapproval/pendingapprovals";
  static const cancelApprovals =
      "$baseURL/api/v1/expenseregistration/expenseregistration/expensecancel?";
  static const empmileagevehicledetails =
      "$baseURL/api/v1/mileageregistration/mileageregistration/empmileagevehicledetails?Emp_Id=";
  static const mileageregistration =
      "$baseURL/api/v1/mileageregistration/mileageregistration/mileageregistration?functionalentity=ExpenseRequisition&";
  static const mileageregistrationview =
      "$baseURL/api/v1/mileageregistration/mileageregistration/";
  static const getNotifications = "$baseURL/api/v1/websocket/notifications1/";
  static const getCustomField =
      "$baseURL/api/v1/perdiemregistration/perdiemregistration/expensecategorycustomfields?expensetype";
  static const getdimensionsDropdownName =
      "$baseURL/api/v1/masters/financemgmt/dimensions/dimensions/dimensionhierarchiesanddimensionhierarchylines/?passeddate=";
  static const getdimensionsDropdownValue =
      "$baseURL/api/v1/masters/financemgmt/dimensions/dimensions/dimensionvalues?page=1&sort_order=asc";
  static const reviewUpDate =
      "$baseURL/api/v1/mileageregistration/mileageregistration/reviewmileageregistrations?";
  static const reviewexpenseregistration =
      "$baseURL/api/v1/expenseregistration/expenseregistration/reviewexpenseregistration?";
  static const cashAdvanceChart =
      "$baseURL/api/v1/dashboard/widgets/ExpenseTrends";
        static const cashadvanceregistrationApi =
      "$baseURL/api/v1/cashadvancerequisition/cashadvanceregistration/reviewcashadvancereturn?";
  static const expenseChart =
      "$baseURL/api/v1/dashboard/widgets/ExpensesThisMonth";
  static const projectExpenseChart =
      "$baseURL/api/v1/dashboard/widgets/ExpensesByProjects";
  static const esCalateUserList =
      "$baseURL/api/v1/masters/usersandrolesmgmt/user/users?filter_query=SYSUsersList.UserId__not_eq%3D";
  static const cashAdvanceList =
      "$baseURL/api/v1/cashadvancerequisition/cashadvanceregistration/cshadvreqid";
  static const cashAdvanceGetall =
      "$baseURL/api/v1/cashadvancerequisition/cashadvanceregistration/getcashadvanceheader";
  static const businessJustification =
      "$baseURL/api/v1/masters/cashadvancemgmt/cashadvance/businessjustification?filter_query=FINBusinessJustification.IsActive__eq%3DTrue&page=1&sort_order=asc";
  static const maxAllowedPercentage =
      "$baseURL/api/v1/masters/cashadvancemgmt/cashadvance/maxallowedpercentage?";
  static const getSpecificCashAdvance =
      "$baseURL/api/v1/cashadvancerequisition/cashadvanceregistration/cashadvance?";
  static const getApprovalDashboardData =
      "$baseURL/api/v1/masters/approvalmanagement/workflowapproval/";
  static const myPendingApproval =
      "$baseURL/api/v1/cashadvancerequisition/cashadvanceregistration/";
  static const cashadvanceregistration =
      "$baseURL/api/v1/cashadvancerequisition/cashadvanceregistration/";
  static const cashadvanceGeneralSettings =
      "$baseURL/api/v1/masters/cashadvancemgmt/cashadvance/cshadvancegeneralsettings?page=1&sort_order=asc";
  static const cashadvancerequisition =
      "$baseURL/api/v1/system/system/sequencenumbers?page=1&limit=10000&sort_by=ModifiedDatetime&sort_order=desc";
    static const emailHubList =
        "$baseURL/api/v1/forwardemailmanagement/fetchallemails?filter_query=STPForwordedEmails.CreatedBy__eq%3D";
  static const emailHubGetSpecific =
      "$baseURL/api/v1/forwardemailmanagement/fetch_specific_emails";
  static const emailHubProcess =
      "$baseURL/api/v1/forwardemailmanagement/processemail";
  static const emailHubReject =
      "$baseURL/api/v1/forwardemailmanagement/rejectemail";
  static const reportsList =
      "$baseURL/api/v1/reports/reports/reportsandreportusermappings/";
  static const expenseReport =
      "$baseURL/api/v1/expensregistration/expensejson/expenseentity?FunctionalEntity=";
       static const expenseregistration =
      "$baseURL/api/v1/expenseregistration/expenseregistration/analytics";
       static const cashadvanceanalytics =
      "$baseURL/api/v1/cashadvancerequisition/cashadvanceregistration/cashadvanceanalytics";
             static const paymentMethodId =
      "$baseURL/api/v1/masters/taxmanagement/tax/paymentmethods"
    "?filter_query=STPPaymentMethods.IsActive__eq%3Dtrue%26STPPaymentMethods.ImportOnly__eq%3Dfalse"
    "&page=1&sort_by=PaymentMethodName&sort_order=asc"
    "&choosen_fields=PaymentMethodName%2CPaymentMethodId";
      static const aiAnalytics =
      "$baseURL/api/v1/aiapis/aiapis/talktodb?";
         static const logOut =
      "$baseURL/api/v1/common/pushnotifications/logout";
}
