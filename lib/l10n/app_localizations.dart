import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_zh.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
    Locale('zh'),
  ];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to DigiXpense'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get setting;
  String get personalDetails;
  String get personalInformation;
  String get firstName;
  String get middleName;
  String get lastName;
  String get personalMailId;
  String get phoneNumber;
  String get gender;
  String get permanentAddress;
  String get street;
  String get city;
  String get zipCode;
  String get searchCountry;
  String get searchState;
  String get sameAsPermanentAddress;
  String get presentAddress;
  String get localizationPreferences;
  String get timeZone;
  String get defaultPayment;
  String get defaultCurrency;
  String get selectLocale;
  String get pleasePickLanguage;
  String get defaultLanguage;
  String get selectDateFormat;
  String get cancel;
  String get submit;
  String get save;
  String get emailSettings;
  String get enterEmail;
  String get invalidEmails;
  String get enterPhoneNumber;
  String get phoneNumberDigitsOnly;
  String get dashboard;
  String get myDashboard;

  String get approvedExpensesTotal;

  String get expensesInProgressTotal;

  String get approvedAdvancesTotal;

  String get advancesInProgressTotal;
  String get mail;
  String get expense;
  String get approvals;
  String get seeMore;
  String get seeLess;
  String get myExpenseTrends;
  String get myExpenseAmountByApprovalStatus;
  String get mySettlementStatus;
  String get myExpensesByProject;
  String get totalExpensesByCategory;
  String get cashAdvance;
  String get myExpenses;
  String get myTeamExpenses;
  String get pendingApprovals;
  String get unProcessed;
  String get myCashAdvances;
  String get myTeamCashAdvances;
  String get emailHub;
  String get approvalHub;
  String get reports;
  String get expensesReports;
  String get settings;
  String get help;
  String get logout;
  String get hello;
  String get hiThere;
  String get welcomeBack;
  String get delete;
  String get unReported;
  String get approved;
  String get cancelled;
  String get rejected;
  String get inProcess;
  String get all;
  String get expenseDashboard;
  String get searchExpenses;
  String get addExpense;
  String get addPerDiem;
  String get addCashAdvanceReturn;
  String get addMileage;
  String get allExpenses;
  String get generalExpenses;
  String get perDiem;
  String get cashAdvanceReturn;
  String get mileage;
  String get noExpensesFound;
  String get loading;
  String get view;
  String get unknownExpenseType;

  String get generalExpenseForm;
  String get projectId;
  String get projectName;
  String get pleaseSelectProject;
  String get taxGroup;
  String get pleaseSelectTaxGroup;
  String get taxAmountRequired;
  String get paidFor;
  String get pleaseSelectCategory;
  String get unit;
  String get uomId;
  String get uomName;
  String get unitAmount;
  String get unitAmountRequired;
  String get quantity;
  String get quantityRequired;
  String get lineAmount;
  String get lineAmountInInr;
  String get accountDistribution;
  String get totalAmount;
  String get comments;
  String get remove;
  String get itemize;
  String get isReimbursable;
  String get isBillable;
  String get finish;
  String get next;
  String get pleaseSelectRequestDate;
  String get requestDate;
  String get selectDate;
  String get paidTo;
  String get selectFromMerchantList;
  String get enterMerchantManually;
  String get selectMerchant;
  String get merchantName;
  String get merchantId;
  String get enterMerchantName;
  String get fieldRequired;
  String get cashAdvanceRequest;
  String get pleaseSelectCashAdvanceField;
  String get requestId;
  String get paidWith;
  String get clear;
  String get zoomIn;
  String get zoomOut;
  String get edit;

  String get tapToUploadDocs;
  String get capture;
  String get upload;
  String get paidAmount;
  String get paidAmountRequired;
  String get enterValidAmount;
  String get currency;
  String get pleaseSelectCurrency;
  String get rate;
  String get rateRequired;
  String get enterValidRate;
  String get amountInInr;
  String get policyViolations;
  String get checkPolicies;
  String get policy1001;
  String get expenseAmountUnderLimit;
  String get receiptRequiredAmount;
  String get descriptionMandatory;
  String get expiredPolicy;

  String get taxId;
  String get back;
  String get taxAmount;
  String get cropImage;
  String get referenceId;
  String get pleaseSelectMerchant;
  String get pleaseEnterMerchantName;
  String get createPerDiem;
  String get editPerDiem;
  String get viewPerDiem;
  String get perDiemDetails;
  String get expenseId;
  String get employeeId;

  String get location;
  String get country;
  String get pleaseSelectLocation;

  String get fromDate;
  String get toDate;
  String get noOfDays;

  String get totalAmountInInr;
  String get purpose;
  String get trackingHistory;
  String get noHistoryMessage;
  String get update;
  String get updateAndAccept;
  String get reject;
  String get resubmit;
  String get approve;
  String get escalate;
  String get action;
  String get selectUser;
  String get enterCommentHere;
  String get commentRequired;
  String get submittedOn;
  String get allocationSettings;
  String get noAllocationDataMessage;
  String get effectiveFrom;
  String get allowanceCategory;
  String get effectiveTo;
  String get pleaseEnterNumberOfDays;
  String get numberOfDaysCannotBeNegative;
  String get enteredDaysCannotExceedAllocated;
  String get pleaseEnterValidNumber;
  String get close;
  String get user;
  String get userName;
  String get userId;
  String get code;
  String get name;
  String get symbol;
  String get editCashAdvanceReturn;
  String get viewCashAdvanceReturn;
  String get receiptDetails;
  String get returnDate;
  String get paymentName;
  String get paymentId;
  String get categoryName;
  String get categoryId;
  String get receiptDate;
  String get pleaseSelectUnit;
  String get paymentInfo;
  String get cashAdvanceReturnForm;
  String get mileageRegistration;
  String get mileageDetails;
  String get mileageDate;
  String get mileageType;
  String get vehicle;
  String get confirm;
  String get turnOffRoundTrip;
  String get endTrip;
  String get startTrip;
  String get addTrip;
  String get roundTrip;
  String get totalDistance;
  String get fillAllTripLocations;
  String get editExpenseApproval;
  String get viewExpenseApproval;
  String get deleteConfirmation;
  String get deleteWarning;
  String get unProcessedExpense;
  String get cashAdvanceRequestForm;
  String get requestedPercentage;
  String get unitEstimatedAmount;
  String get unitAmountIsRequired;
  String get cashAdvanceRequisitionId;
  String get totalEstimatedAmountInInr;
  String get totalEstimatedAmountIn;
  String get search;
  String get employeeName;
  String get businessJustification;
    String get justification;
    String get justificationRequired ;
  String get enterJustification;
  String get pleaseEnterJustification ;
  String get somethingWentWrong;
  String get timezoneName ;
    String get timezoneCode ;
    String get timezoneId  ;
  String get languageName ;
  
  String get languageId  ;
  String get id;
  String get paidAmountExceedsMaxPercentage;
  String get totalRequestedAmount;
  String get pdfViewerNotFound;
  String get noAppToViewPdf;
  String get ok;
  String get getPdfReader;
  String get preview;
  String get processed;
  String get from;
  String get attachments;
  String get noEmailsFound;
  String get rejectEmail;
  String get reasonForRejection;
  String get emailRejectedSuccessfully;
  String get errorRejectingEmail;
  String get editReport;
  String get viewReport;
  String get createReport;
  String get reportName;
  String get enterReportTitle;
  String get functionalArea;
  String get expenseRequisition;
  String get cashAdvanceRequisition;
  String get dataset;
  String get unknownDataset;
  String get selectDataset;
  String get description;
  String get addShortDescription;
  String get tags;
  String get enterTags;
  String get applicableFor;
  String get selectAudience;
  String get filterRule;
  String get addGroup;
  String get group;
  String get removeGroup;
  String get addRuleToGroup;
  String get availableColumnsHeader;
  String get availableColumnsLines;
  String get noColumnsAvailable;

  String get table;
  String get column;
  String get condition;
  String get enterValueToMatch;

  String get enterStartingValue;
  String get to;
  String get enterEndingValue;
  String get removeRule;
  String get or;
  String get and;
  String get addReport;
  String get noReportFound;
  String get reportAvailability;
  String get generateReport;
  String get export;
  String get applyFilters;
  String get noDataFound;
  String get totalRejectedAmount;
  String get lastSettlementDate;
  String get basicFiltration;
  String get advancedFiltering;
  String get assignUsers;
  String get availableUsers;
  String get moveAll;
  String get moveSelected;
  String get saveReport;
  String get pleaseAssignAnyUser;
  String get print;
  String get printAll;
  String get totalAmountTrans;
  String get totalAmountReporting;
  String get approvalStatus;
  String get expenseType;
  String get expenseStatus;
  String get currencyCode;
  String get reportingCurrency;
  String get source;
  String get expenseReport;
  String get expenseTrans;
  String get lineNumber;
  String get expenseCategoryId;
  String get unitPriceTrans;
  String get lineAmountTrans;
  String get type;
  String get format;
  String get errorLoadingImage;
  String get pdfDocument;
  String get activityLog;
  String get totalTransAmount;
  String get noPreviewAvailable;
  String get filterations;
  String get generalSettings;
  String get field;
  String get filteredBy;
  String get pleaseFillAllRequiredFields;
  String get generalExpense;

  String get selectDimensions;
  String get percentage;
  String get amount;
  String get report;
  String get addSplit;
  String get askQuestionPrompt;
  String get tryAsking;
  String get aiAnalytics;
  String get networkError;
  String get requestError;
  String get expenseDistribution;
  String get breakdownHeader;
  String get aiAnalyticsWelcome;
  // Dynamic string for warnings
  String totalPercentageMustBe100(double current);
  String get skip;
  String get groupIsEmpty;
  String get pleaseSelectTableForRule;
  String get pleaseSelectColumnForRule;
  String get pleaseSelectConditionForRule;
  String get pleaseEnterValueForRule;
  String get pleaseEnterFromToValuesForBetween;
  String get step;
  String get previous;
  String get functionalEntity;
  String get selectFunctionalEntity;
  String get sortBy;
  String get selectSortField;
  String get sortOrder;
  String get selectOrder;
  String get advancedFiltration;
  String get addNewGroup;
  String get chooseTablesToViewInReport;
  String get transData;
  String get documentAttachments;
  String get accountingDistributions;
  String get expenseCategoryCustomFields;
  String get transCustomFieldsValues;
  String get headerCustomFieldsValues;
  String get workflowHistory;
  String get lightheme;
  String get darktheme;
  String get value;
  String get notifications;
  String get unread;
  String get allNotifications;

  String get exitForm;
  String get exitWarning;
  String get continueText;
  String get duplicateReceiptWarning;
  String get expenseDetails;
  String get extractingReceipt;
  String get duplicateReceiptDetected;
  String get item;
  String get pleaseWait;
  String get leaveCode;
    String get reliever;
  String get department;
  String get dates;
  String get notifyingUsers;
  String get contactNumber;
  String get availabilityDuringLeave;
  String get availability;
  String get outOfOfficeMessage;
  String get notifyHR;
  String get notifyTeamMembers;
  String get paidLeave;
  String get totalDays;
  String get saveAsDraft;
  String get editLeaveRequest;
  String get newLeaveRequest;
String get days;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
