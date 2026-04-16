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
    String get example;
      String get onlyLettersAndNumbers ;
        String get zipMustIncludeNumber ;
          String get noMatchingStates ;
          String get invalidPhoneNumber  ;
          String get emailsForReceiptForwarding;
  String get submit;
  String get save;
  String get emailSettings;
  String get enterEmail;
  String get invalidEmails;
  String get enterPhoneNumber;
  String get phoneNumberDigitsOnly;
  String get dashboard;
  String get myDashboard;
  String get punchInOut;
  String get punchInOutList;
  String get myTeamAttendance;
  String get timesheets;
  String get myTeamTimesheets;
  String get payroll;
  String get myPayslips;
  String get allPayslips;
  String get board;
  String get approvedExpensesTotal;
 String get leaveCancellation;  // New
  String get myTimesheets;    
  String get expensesInProgressTotal;
String get fullyCancel;
  String get partialCancel;
  String get cardView;
  String get calendarView;
  String get month;
  String get week;
  String get day;
  String get approvedAdvancesTotal;
 String get wouldYouLikeToPunch;
  String get punchOut;
  String get punchIn;
  String get status;
  String get lastSession;
  String get lastIn;
  String get lastOut;
  String get totalTime;
  String get selfieVerification;
  String get retake;
  String get currentLocation;
  String get myLocation;
  String get loading;
  String get fetchingLocation;
  String get locationPermissionDenied;
  String get failedToFetchLocation;
  String get cameraPermissionDenied;
  String get networkError;
  String get punchFailed;
  String get punchedInSuccessfully;
  String get punchedOutSuccessfully;
  String get noPreviousSession;
  String get locationNotAvailable;
  String get takeSelfie;
  String get selfiePlaceholder;
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
    String get misReports;
String get reportedAmountNotWithinRange;
String get count;
  String get cashAdvanceReturn;
  String get mileage;
  String get noExpensesFound;
String get createdBy;
String get label; 
String get stage;
String get shelfNameRequired;
  String get view;
  String get unknownExpenseType;
String get timesheet;
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
    String get totalAmountIN;
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
    String get add;
     String get reason;
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
  String get branchEmployees;
String get departmentEmployees;
String get viewType;
String get timeDetails;
String get myLeaveCancellations;
  String get totalAmountInInr;
  String get leaveFullCancellation;
String get reasonForCancellation;
String get pleaseEnterCancellationReason;
String get leavePartialCancellation;
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
  String get uploadFileOrDragDrop;
  String get uploadAttachments;
  String get businessJustification;
  String get justification;
  String get justificationRequired;
  String get enterJustification;
  String get pleaseEnterJustification;
  String get somethingWentWrong;
  String get timezoneName;
  String get timezoneCode;
  String get timezoneId;
  String get languageName;
String get totalRequestedAmountInINR;
String get lineEstimatedAmountInINR;
String get lineRequestedAmountInINR;
  String get languageId;
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
  String get addRule;
  String get table;
    String get toDateValidation ;
       String get confirmLogout  ;
          String get logoutConfirmationMessage  ;
       
            
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
  String get myAttendanceList;
  String get totalHours;
  String get transactionId;
  String get punchInTime;
  String get punchOutTime;
  String get totalDuration;
  String get captureType;
  String get punchInGeofenceId;
  String get punchOutGeofenceId;
  String get isRegularized;
  String get punchInLocation;
  String get punchOutLocation;
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
String get periodType;
String get periodTypeIsRequired;
String get timeSheetRequestForm;
String get dateRange;
String get lineItem;
String get timeSheetPendingApprovals;
String get employees;
String get employeeGroups;
String get timesheetRequisitionId;

String get addLine;
String get addTimer;

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
    String get newCreateLeaveRequest;
  String get leaveRequisitionId;
  String get delegatedAuthority;
  String get locationDuringLeave;
  String get availableForUrgentMatters;
  String get notAvailable;
  String get dayType;
  String get fullDay;
  String get firstHalf;
  String get secondHalf;
  String get ofLeave;
  String get total;
  String get appliedDate;
  String get days;
  String get myTeamLeaveDashboard;
  String get noEventsFor;
  String get duration;
String get viewTeamMemberAttendance;
  String get viewAttendanceTransaction;
  String get mon;
  String get tue;
  String get wed;
  String get thu;
  String get fri;
  String get sat;
  String get sun;
 String get addLeaveRequest;
  String get noLeaveData;
  String get remaining;
  String get outOf;
  String get balance;
  String get leaveRequisition;
  String get myLeave;
   String get leave;
  String get myTeamLeave;
  String get myTeamLeaveCancellation;
  String get boardDashboard;
  String get createBoard;
  String get boardName;
  String get boardTemplate;
  String get referenceName;
  String get areaName;
String get sendToMail;
String get send;
String get download;
String get payslipsNotAvailable;
String get tableView;
String get timeTracker;
String get start;
String get pause;
String get resume;
String get complete;
String get generateTimeSheet;
String get generateAndSubmit;
String get noTimeRunsFound;
String get active;
String get runId;
String get segment;
String get timeRunId;
String get sequence;
String get end;
String get noEventsFound;
String get event;
String get occurred;
String get started;
String get ended;
String get eventTypeOccurred;
String get details;
String get viewDetails;
String get segmentId;
String get segmentSequence;
String get startTime;
String get endTime;
String get durationInHours;
String get endEvent;
String get updateDetails;
String get editSegment;
String get eventType;

  String get boardTaskDetails;
  String get taskName;
  String get enterTaskName;
  String get selectTags;
  String get tagId;
  String get tagName;
  String get selectUsers;
  String get estimatedHours;
  String get cardType;
  String get priority;
  String get low;
  String get high;
  String get medium;
  String get urgent;
  String get actualHours;
  String get version;
  String get parentTask;
  String get taskId;
  String get selectDependency;
  String get checklist;
  String get addItem;
  String get showInCard;
  String get enterNotes;
  String get addAttachment;
  String get posting;
  String get comment;
  String get noCommentsYet;
  String get grid;
  String get boardSettings;
String get addTimeSheets;
  String get addShelf;
  String get addTask;
  String get noTasksFound;
  String get deleteTask;
String get plannedStartDate;
String get plannedEndDate;
String get actualStartDate;
String get actualEndDate;
  String get noDueDate;
  String get shelfName;
  String get searchTasksUsersTags;
  String get assigned;
  String get editShelf;
  String get areYouSureDeleteTask;
  String get dueDate;
  String get addBoardMembers;
    String get visibilityOfYourBoard;
  String get public;
  String get visibleToEveryone;
  String get private;
  String get onlySelectedUsers;
  String get enterBoardName;
  String get boardNameIsRequired;
  String get selectTemplate;
  String get pleaseSelectATemplate;
  String get templateIsRequired;
  String get selectGroups;
  String get areYouSureDeleteBoard;
  String get thisActionCannotBeUndone;
  String get deleteBoard;
    String get boardOwnerName;
  String get defaultSortingOrder;
  String get byAssignee;
  String get enableTimeTracking;
  String get referenceType;
  String get boardTheme;
  String get dark;
  String get light;
  String get systemDefault;
  String get backgroundImage;
  String get url;
  String get fileUpload;
  String get imageUrl;
  String get uploadImage;
  String get removeMemberFromBoard;
    String get members;



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
