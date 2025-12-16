import 'app_localizations.dart';

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get welcome => 'مرحبًا بك في DigiXpense';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get setting => 'إعدادات';
  @override String get firstName => 'الاسم الأول';
@override String get middleName => 'الاسم الأوسط';
@override String get lastName => 'اسم العائلة';
@override String get personalMailId => 'البريد الإلكتروني الشخصي';
@override String get phoneNumber => 'رقم الهاتف';
@override String get gender => 'الجنس';
@override String get permanentAddress => 'العنوان الدائم';
@override String get street => 'الشارع';
@override String get city => 'المدينة';
@override String get searchCountry => 'البحث عن الدولة';
@override String get searchState => 'البحث عن الولاية';
@override String get zipCode => 'الرمز البريدي';
@override String get sameAsPermanentAddress => 'نفس العنوان الدائم';
@override String get presentAddress => 'العنوان الحالي';
@override String get localizationPreferences => 'الإعدادات والتفضيلات';
@override String get timeZone => 'المنطقة الزمنية';
@override String get defaultPayment => 'طريقة الدفع الافتراضية';
@override String get defaultCurrency => 'العملة الافتراضية';
@override String get selectLocale => 'اختر اللغة';
@override String get pleasePickLanguage => 'يرجى اختيار لغة';
@override String get defaultLanguage => 'اللغة الافتراضية';
@override String get selectDateFormat => 'اختر تنسيق التاريخ';
@override String get cancel => 'إلغاء';
@override String get submit => 'إرسال';
@override String get emailSettings => 'إعدادات البريد الإلكتروني';
@override String get enterEmail => 'أدخل البريد الإلكتروني';
@override String get invalidEmails => 'عنوان بريد إلكتروني أو أكثر غير صالح';
@override String get enterPhoneNumber => 'يرجى إدخال رقم الهاتف';
@override String get phoneNumberDigitsOnly => 'يجب أن يتكون رقم الهاتف من 10 أرقام';
@override String get save => 'حفظ';
@override
String get approvedExpensesTotal => 'المصروفات المعتمدة (الإجمالي)';

@override
String get expensesInProgressTotal => 'المصروفات قيد المعالجة (الإجمالي)';

@override
String get approvedAdvancesTotal => 'السلف المعتمدة (الإجمالي)';

@override
String get advancesInProgressTotal => 'السلف قيد المعالجة (الإجمالي)';
@override
String get dashboard => 'لوحة التحكم';
@override
String get expense => 'المصروفات';

@override
String get approvals => 'الموافقات';
@override
String get seeMore => 'عرض المزيد ▼';

@override
String get seeLess => 'عرض أقل ▲';
@override
String get mail => 'البريد';
@override
String get myDashboard => 'لوحة التحكم الخاصة بي';
@override
String get personalInformation => 'المعلومات الشخصية';
@override
String get personalDetails => 'البيانات الشخصية';
@override
String get myExpenseTrends => 'اتجاهات مصاريفي';

@override
String get myExpenseAmountByApprovalStatus => 'مبلغ مصاريفي حسب حالة الموافقة';

@override
String get mySettlementStatus => 'حالة التسوية الخاصة بي';

@override
String get myExpensesByProject => 'مصاريفي حسب المشروع';

@override
String get totalExpensesByCategory => 'إجمالي المصاريف حسب الفئة';

@override
String get cashAdvance => 'السلفة';
@override
String get myExpenses => 'مصاريفي';

@override
String get myTeamExpenses => 'مصاريف فريقي';

@override
String get pendingApprovals => 'الموافقات المعلقة';

@override
String get unProcessed => 'غير معالج';

@override
String get myCashAdvances => 'سلفي النقدية';

@override
String get myTeamCashAdvances => 'سلف فريقي النقدية';

@override
String get emailHub => 'مركز البريد';

@override
String get approvalHub => 'مركز الموافقات';

@override
String get reports => 'التقارير';

@override
String get expensesReports => 'تقارير المصاريف';

@override
String get settings => 'الإعدادات';

@override
String get help => 'مساعدة';

@override
String get logout => 'تسجيل الخروج';

@override
String get hello => 'مرحباً';

@override
String get hiThere => 'مرحباً بك';

@override
String get welcomeBack => 'مرحباً بعودتك';
 @override
  String get delete => 'حذف';
  @override
  String get unReported => 'غير مُبلّغ';
  @override
  String get approved => 'موافق عليه';
  @override
  String get cancelled => 'أُلغيت';
  @override
  String get rejected => 'مرفوض';
  @override
  String get inProcess => 'قيد المعالجة';
  @override
  String get all => 'الكل';
  @override
  String get expenseDashboard => 'لوحة المصاريف';
  @override
  String get searchExpenses => 'ابحث عن المصاريف...';
  @override
  String get addExpense => 'إضافة مصروف';
  @override
  String get addPerDiem => 'إضافة بدل يومي';
  @override
  String get addCashAdvanceReturn => 'إضافة تسوية السلفة';
  @override
  String get addMileage => 'إضافة الأميال';
  @override
  String get allExpenses => 'جميع المصاريف';
  @override
  String get generalExpenses => 'المصاريف العامة';
  @override
  String get perDiem => 'البدل اليومي';
  @override
  String get cashAdvanceReturn => 'تسوية السلفة';
  @override
  String get mileage => 'الأميال';
  @override
  String get noExpensesFound => 'لم يتم العثور على مصاريف';
  @override
  String get loading => 'جارٍ التحميل...';
  @override
  String get view => 'عرض';
  @override
  String get unknownExpenseType => 'نوع مصروف غير معروف:';
  @override String get generalExpenseForm => 'نموذج المصروفات العامة';
@override String get projectId => 'معرف المشروع';
@override String get projectName => 'اسم المشروع';
@override String get pleaseSelectProject => 'يرجى اختيار مشروع';
@override String get taxGroup => 'مجموعة الضرائب';
@override String get pleaseSelectTaxGroup => 'يرجى اختيار مجموعة ضرائب';
@override String get taxAmountRequired => 'مطلوب إدخال مبلغ الضريبة';
@override String get paidFor => 'مدفوع مقابل';
@override String get pleaseSelectCategory => 'يرجى اختيار فئة';
@override String get unit => 'الوحدة';
@override String get uomId => 'معرف وحدة القياس';
@override String get uomName => 'اسم وحدة القياس';
@override String get unitAmount => 'مبلغ الوحدة';
@override String get unitAmountRequired => 'مطلوب إدخال مبلغ الوحدة';
@override String get quantity => 'الكمية';
@override String get quantityRequired => 'مطلوب إدخال الكمية';
@override String get lineAmount => 'مبلغ السطر';
@override String get lineAmountInInr => 'مبلغ السطر بالروبية الهندية';
@override String get accountDistribution => 'توزيع الحساب';
@override String get totalAmount => 'إجمالي المبلغ:';
@override String get comments => 'التعليقات';
@override String get remove => 'إزالة';
@override String get itemize => 'تفصيل';
@override String get isReimbursable => 'قابل للتعويض';
@override String get isBillable => 'قابل للفوترة';
@override String get finish => 'إنهاء';
@override String get next => 'التالي';
@override String get pleaseSelectRequestDate => 'يرجى اختيار تاريخ الطلب';
@override String get requestDate => 'تاريخ الطلب';
@override String get selectDate => 'اختر التاريخ';
@override String get paidTo => 'مدفوع إلى';
@override String get selectFromMerchantList => 'اختر من قائمة التجار';
@override String get enterMerchantManually => 'لا تجد التاجر؟ أدخل يدوياً';
@override String get selectMerchant => 'اختر التاجر';
@override String get merchantName => 'اسم التاجر';
@override String get merchantId => 'معرف التاجر';
@override String get enterMerchantName => 'أدخل اسم التاجر';
@override String get fieldRequired => 'هذا الحقل مطلوب';
@override String get cashAdvanceRequest => 'طلب سلفة نقدية';
@override String get pleaseSelectCashAdvanceField => 'يرجى اختيار حقل السلفة النقدية';
@override String get requestId => 'معرف الطلب';
@override String get paidWith => 'مدفوع باستخدام';
@override String get clear => 'مسح';
@override String get zoomIn => 'تكبير';
@override String get zoomOut => 'تصغير';
@override String get edit => 'تعديل';
@override String get tapToUploadDocs => 'اضغط لرفع المستندات';
@override String get capture => 'التقاط';
@override String get upload => 'رفع';
@override String get paidAmount => 'المبلغ المدفوع';
@override String get paidAmountRequired => 'مطلوب إدخال المبلغ المدفوع';
@override String get enterValidAmount => 'أدخل مبلغاً صالحاً';
@override String get currency => 'العملة *';
@override String get pleaseSelectCurrency => 'يرجى اختيار العملة';
@override String get rate => 'السعر';
@override String get rateRequired => 'مطلوب إدخال السعر';
@override String get enterValidRate => 'أدخل سعراً صالحاً';
@override String get lightheme => 'ألوان الثيم الفاتح';
@override String get darktheme => 'ألوان الثيم الداكن';
@override String get amountInInr => 'المبلغ بالروبية الهندية';
@override String get policyViolations => 'انتهاكات السياسة';
@override String get checkPolicies => 'تحقق من السياسات';
@override String get policy1001 => 'السياسة 1001';
@override String get expenseAmountUnderLimit => 'مبلغ المصروف أقل من الحد';
@override String get receiptRequiredAmount => 'المبلغ يتطلب إيصالاً: أي مصروف يجب أن يكون له إيصال';
@override String get descriptionMandatory => 'إذا جعل المسؤول الوصف إلزامياً لجميع المصروفات';
@override String get expiredPolicy => 'المصروف المنتهي يعتبر مخالفة للسياسة';
@override String get notifications => 'الإشعارات';
@override String get unread => 'غير مقروءة';
@override String get allNotifications => 'جميع الإشعارات';
@override String get taxId => 'الرقم الضريبي';
@override String get back => 'رجوع';
@override String get taxAmount => 'قيمة الضريبة';
@override String get cropImage => 'اقتصاص الصورة';
@override String get referenceId => ' المرجع';
@override String get pleaseSelectMerchant => 'يرجى اختيار تاجر';
@override String get pleaseEnterMerchantName => 'يرجى إدخال اسم التاجر';
@override String get createPerDiem => 'إنشاء بدل يومي';
@override String get editPerDiem => 'تعديل بدل يومي';
@override String get viewPerDiem => 'عرض بدل يومي';
@override String get perDiemDetails => 'تفاصيل البدل اليومي';
@override String get expenseId => 'معرّف المصروف';
@override String get employeeId => 'معرّف الموظف';
@override String get reliever => 'البديل';
@override String get department => 'القسم';
@override String get dates => 'التواريخ';
@override String get notifyingUsers => 'المستخدمون المُخطرون';
@override String get contactNumber => 'رقم الاتصال';
@override String get availabilityDuringLeave => 'التوفر أثناء الإجازة';
@override String get availability => 'التوفر';
@override String get outOfOfficeMessage => 'رسالة خارج المكتب';
@override String get notifyHR => 'إخطار الموارد البشرية';
@override String get notifyTeamMembers => 'إخطار أعضاء الفريق';
@override String get paidLeave => 'إجازة مدفوعة الأجر';
@override String get totalDays => 'إجمالي الأيام';
@override String get saveAsDraft => 'حفظ كمسودة';
@override String get editLeaveRequest => 'تعديل طلب الإجازة';
@override String get newLeaveRequest => 'طلب إجازة جديد';
@override
String get days => 'الأيام';

  @override
  String get leaveCode => 'رمز الإجازة';
@override
String get exitWarning => 'ستفقد أي بيانات غير محفوظة. هل تريد الخروج؟';
@override
String get duplicateReceiptWarning => 'يبدو أن هذه الإيصال مكرر. هل تريد المتابعة؟';

@override
String get continueText => 'متابعة';

@override
String get duplicateReceiptDetected => 'تم اكتشاف إيصال مكرر';

@override
String get extractingReceipt => 'نحن نقوم باستخراج إيصالك';

@override
String get exitForm => 'خروج من النموذج';
@override String get location => 'الموقع';
@override String get country => 'الدولة';
@override String get pleaseSelectLocation => 'يرجى اختيار موقع';
@override
String get pleaseWait => 'يرجى الانتظار...';

@override String get fromDate => 'من تاريخ';
@override String get toDate => 'إلى تاريخ';
@override String get noOfDays => 'عدد الأيام';
@override String get totalAmountInInr => 'المبلغ الإجمالي بالروبية';
@override String get purpose => 'الغرض';
@override String get trackingHistory => 'سجل التتبع';
@override String get noHistoryMessage => 'هذا المصروف لا يحتوي على سجل. يرجى التفكير في إرساله للموافقة.';@override String get userName => 'اسم المستخدم';
@override String get userId => 'معرّف المستخدم';
@override String get code => 'رمز';
@override String get name => 'الاسم';
@override String get symbol => 'رمز';
@override String get receiptDetails => 'تفاصيل الإيصال';
@override String get returnDate => 'تاريخ الإرجاع';
@override String get paymentName => 'اسم الدفع';
@override String get paymentId => 'معرّف الدفع';
@override String get item => 'عنصر';
@override String get categoryName => 'اسم الفئة';
@override String get categoryId => 'معرّف الفئة';
@override String get receiptDate => 'تاريخ الإيصال';
@override String get pleaseSelectUnit => 'يرجى اختيار وحدة';
@override String get paymentInfo => 'معلومات الدفع';
@override String get expenseDetails => 'تفاصيل المصروف';
@override String get cashAdvanceReturnForm => 'نموذج إرجاع السلفة النقدية';
@override String get mileageRegistration => 'تسجيل المسافة';
@override String get mileageDetails => 'تفاصيل المسافة';
@override String get mileageDate => 'تاريخ المسافة';
@override String get mileageType => 'نوع المسافة';
@override String get vehicle => 'المركبة';
@override String get confirm => 'تأكيد';
@override String get turnOffRoundTrip => 'إيقاف الرحلة ذهابًا وإيابًا';
@override String get endTrip => 'إنهاء الرحلة';
@override String get startTrip => 'بدء الرحلة';
@override String get addTrip => 'إضافة رحلة';
@override String get roundTrip => 'رحلة ذهابًا وإيابًا';
@override String get totalDistance => 'المسافة الإجمالية';
@override String get fillAllTripLocations => 'يرجى إدخال جميع مواقع الرحلة قبل الإرسال.';
@override String get editExpenseApproval => 'تعديل موافقة المصروف';
@override String get viewExpenseApproval => 'عرض موافقات المصروف';
@override String get deleteConfirmation => 'هل أنت متأكد أنك تريد الحذف؟';
@override String get deleteWarning => 'لا يمكن التراجع عن هذا الإجراء.';
@override String get unProcessedExpense => 'المصروف غير المعالج';
@override String get cashAdvanceRequestForm => 'نموذج طلب السلفة النقدية';
@override String get requestedPercentage => 'النسبة المطلوبة';
@override String get unitEstimatedAmount => 'المبلغ التقديري للوحدة';
@override String get unitAmountIsRequired => 'مطلوب مبلغ الوحدة';
@override String get cashAdvanceRequisitionId => 'معرف طلب السلفة النقدية';
@override String get totalEstimatedAmountInInr => 'إجمالي المبلغ التقديري بالروبية الهندية';
@override String get totalEstimatedAmountIn => 'مالي المبلغ التقديري بالروبية الهندية';
@override
String get employeeName => 'اسم الموظف';
@override
String get justification => 'التبرير';
@override
String get justificationRequired => 'التبرير مطلوب';

@override
String get enterJustification => 'أدخل التبرير';

@override
String get pleaseEnterJustification => 'يرجى إدخال التبرير';

@override
String get somethingWentWrong => 'حدث خطأ ما:';
@override
String get timezoneName => 'اسم المنطقة الزمنية';

@override
String get timezoneCode => 'رمز المنطقة الزمنية';

@override
String get timezoneId => 'معرف المنطقة الزمنية';

@override
String get languageName => 'اسم اللغة';

@override
String get languageId => 'معرف اللغة';

@override String get search => 'بحث';
@override String get businessJustification => 'مبرر العمل';
@override String get id => 'المعرف';
@override String get paidAmountExceedsMaxPercentage => 'المبلغ المدفوع يتجاوز النسبة المئوية المسموح بها';
@override String get totalRequestedAmount => 'إجمالي المبلغ المطلوب';
@override String get pdfViewerNotFound => 'عارض PDF غير موجود';
@override String get noAppToViewPdf => 'لا يوجد تطبيق متاح لعرض ملفات PDF. يرجى تثبيت تطبيق لقراءة PDF.';
@override String get ok => 'موافق';
@override String get getPdfReader => 'احصل على قارئ PDF';
@override String get preview => 'معاينة';
@override String get processed => 'تمت المعالجة';
@override String get from => 'من:';
@override String get attachments => 'المرفقات';
@override String get noEmailsFound => 'لم يتم العثور على رسائل بريد إلكتروني';
@override String get close => 'إغلاق';
@override String get user => 'مستخدم';
@override String get editCashAdvanceReturn => 'تعديل إرجاع السلفة النقدية';
@override String get viewCashAdvanceReturn => 'عرض إرجاع السلفة النقدية';
@override String get rejectEmail => 'رفض البريد الإلكتروني';
@override String get reasonForRejection => 'سبب الرفض';
@override String get emailRejectedSuccessfully => 'تم رفض البريد الإلكتروني بنجاح';
@override String get errorRejectingEmail => 'خطأ في رفض البريد الإلكتروني:';
@override String get editReport => 'تعديل التقرير';
@override String get viewReport => 'عرض التقرير';
@override String get createReport => 'إنشاء تقرير';
@override String get reportName => 'اسم التقرير';
@override String get enterReportTitle => 'أدخل عنوان التقرير';
@override String get functionalArea => 'المجال الوظيفي';
@override String get expenseRequisition => 'طلب المصروفات';
@override String get cashAdvanceRequisition => 'طلب السلفة النقدية';
@override String get dataset => 'مجموعة البيانات';
@override String get unknownDataset => 'مجموعة بيانات غير معروفة';
@override String get selectDataset => 'اختر مجموعة بيانات';
@override String get description => 'الوصف';
@override String get addShortDescription => 'أضف وصفاً قصيراً (اختياري)';
@override String get tags => 'الوسوم';
@override String get enterTags => 'أدخل الوسوم';
@override String get applicableFor => 'ينطبق على';
@override String get selectAudience => 'اختر الجمهور';
@override String get filterRule => 'قاعدة التصفية';
@override String get addGroup => 'إضافة مجموعة';
@override String get group => 'مجموعة';
@override String get removeGroup => 'إزالة المجموعة';
@override String get addRuleToGroup => 'إضافة قاعدة إلى هذه المجموعة';
@override String get availableColumnsHeader => 'الأعمدة المتاحة (الرأس)';
@override String get availableColumnsLines => 'الأعمدة المتاحة (السطور)';
@override String get noColumnsAvailable => 'لا توجد أعمدة متاحة للاختيار';
@override String get table => 'جدول';
@override String get column => 'عمود';
@override String get condition => 'الشرط';
@override String get enterValueToMatch => 'أدخل القيمة للمطابقة';
@override String get enterStartingValue => 'أدخل القيمة الابتدائية';
@override String get to => 'إلى';
@override String get enterEndingValue => 'أدخل القيمة النهائية';
@override String get removeRule => 'إزالة القاعدة';
@override String get or => 'أو';
@override String get and => 'و';
@override String get value => 'القيمة';
@override String get addReport => 'إضافة تقرير';
@override String get noReportFound => 'لم يتم العثور على تقرير';
@override String get reportAvailability => 'توفر التقرير';
@override String get generateReport => 'إنشاء تقرير';
@override String get export => 'تصدير';
@override String get applyFilters => 'تطبيق الفلاتر';
@override String get noDataFound => 'لم يتم العثور على بيانات';
@override String get totalRejectedAmount => 'إجمالي المبلغ المرفوض';
@override String get lastSettlementDate => 'تاريخ التسوية الأخير';
@override String get basicFiltration => 'تصفية أساسية';
@override String get advancedFiltering => 'تصفية متقدمة';
@override String get groupIsEmpty => 'المجموعة فارغة. يرجى إضافة قواعد أو إزالة المجموعة.';
@override String get pleaseSelectTableForRule => 'يرجى اختيار جدول للقاعدة في المجموعة';
@override String get pleaseSelectColumnForRule => 'يرجى اختيار عمود للقاعدة في المجموعة';
@override String get pleaseSelectConditionForRule => 'يرجى اختيار شرط للقاعدة في المجموعة';
@override String get pleaseEnterValueForRule => 'يرجى إدخال قيمة للقاعدة';
@override String get pleaseEnterFromToValuesForBetween => 'يرجى إدخال قيمتي "من" و "إلى" لشرط "بين" في القاعدة';
@override String get assignUsers => 'تعيين المستخدمين';
@override String get availableUsers => 'المستخدمون المتاحون';
@override String get moveAll => 'نقل الكل';
@override String get moveSelected => 'نقل المحدد';
@override String get saveReport => 'حفظ التقرير';
@override String get pleaseAssignAnyUser => 'يرجى تعيين أي مستخدم';
@override String get print => 'طباعة';
@override String get printAll => 'طباعة الكل';
@override String get totalAmountTrans => 'إجمالي المبلغ المحول';
@override String get totalAmountReporting => 'إجمالي مبلغ التقرير';
@override String get approvalStatus => 'حالة الموافقة';
@override String get expenseType => 'نوع المصروف';
@override String get expenseStatus => 'حالة المصروف';
@override String get currencyCode => 'رمز العملة';
@override String get reportingCurrency => 'عملة التقرير';
@override String get source => 'المصدر';
@override String get expenseReport => 'تقرير المصروفات';
@override String get expenseTrans => 'معاملة المصروف';
@override String get lineNumber => 'رقم السطر';
@override String get expenseCategoryId => 'معرف فئة المصروف';
@override String get unitPriceTrans => 'سعر الوحدة';
@override String get lineAmountTrans => 'مبلغ السطر';
@override String get type => 'النوع';
@override String get format => 'التنسيق';
@override String get errorLoadingImage => 'خطأ في تحميل الصورة';
@override String get pdfDocument => 'ملف PDF';
@override String get activityLog => 'سجل النشاط';
@override String get totalTransAmount => 'إجمالي المبلغ المحول';
@override String get noPreviewAvailable => 'لا تتوفر معاينة';
@override String get filterations => 'الترشيحات';
@override String get generalSettings => 'الإعدادات العامة';
@override String get field => 'الحقل';
@override String get filteredBy => 'مفلتر حسب';
@override String get pleaseFillAllRequiredFields => 'يرجى ملء جميع الحقول المطلوبة';
@override String get generalExpense => 'المصروفات العامة';
  @override
  String get skip => 'تخطي';
@override
  String get askQuestionPrompt => "اطرح سؤالًا عن بياناتك...";
  @override
  String get tryAsking => "حاول أن تسأل:";
  @override
  String get aiAnalytics => "تحليلات الذكاء الاصطناعي";
  @override
  String get networkError => "خطأ في الشبكة. يرجى التحقق من الاتصال.";
  @override
  String get requestError => "عذرًا، لم أتمكن من معالجة طلبك. حاول مرة أخرى.";
  @override
  String get expenseDistribution => "توزيع المصاريف";
  @override
  String get breakdownHeader => "إليك التفاصيل:";
  @override
  String get aiAnalyticsWelcome => "مرحبًا بك في تحليلات الذكاء الاصطناعي! يمكنني مساعدتك في تحليل بيانات المصاريف. اسألني أي شيء!";

  @override
  String get selectDimensions => 'اختر الأبعاد';

  @override
  String get percentage => 'النسبة المئوية *';

  @override
  String get amount => 'المبلغ';

  @override
  String get report => 'التقرير';

  @override
  String get addSplit => 'إضافة تقسيم';

  @override
  String totalPercentageMustBe100(double current) =>
      'يجب أن يكون المجموع 100٪. الحالي: ${current.toStringAsFixed(2)}٪';
@override String get step => 'خطوة';
@override String get previous => 'السابق';
@override String get functionalEntity => 'الكيان الوظيفي';
@override String get selectFunctionalEntity => 'اختر الكيان الوظيفي';
@override String get sortBy => 'ترتيب حسب';
@override String get selectSortField => 'اختر حقل الترتيب';
@override String get sortOrder => 'ترتيب الفرز';
@override String get selectOrder => 'اختر الترتيب';
@override String get advancedFiltration => 'تصفية متقدمة';
@override String get addNewGroup => 'إضافة مجموعة جديدة';
@override String get chooseTablesToViewInReport => 'اختر الجداول لعرضها في التقرير';
@override String get transData => 'بيانات المعاملة';
@override String get documentAttachments => 'المرفقات';
@override String get accountingDistributions => 'توزيعات محاسبية';
@override String get expenseCategoryCustomFields => 'حقول مخصصة لفئة المصاريف';
@override String get transCustomFieldsValues => 'قيم الحقول المخصصة للمعاملة';
@override String get headerCustomFieldsValues => 'قيم الحقول المخصصة للرأس';
@override String get workflowHistory => 'سجل سير العمل';

@override String get update => 'تحديث';
@override String get updateAndAccept => 'تحديث وقبول';
@override String get reject => 'رفض';
@override String get resubmit => 'إعادة التقديم';
@override String get approve => 'موافقة';
@override String get escalate => 'تصعيد';
@override String get action => 'إجراء';
@override String get selectUser => 'اختر مستخدمًا';
@override String get enterCommentHere => 'أدخل تعليقك هنا';
@override String get commentRequired => 'التعليق مطلوب';
@override String get submittedOn => 'تم التقديم في';
@override String get allocationSettings => 'إعدادات التوزيع';
@override String get noAllocationDataMessage => 'لم يتم العثور على بيانات توزيع للموقع المحدد. حاول موقعًا آخر.';
@override String get effectiveFrom => 'ساري من';
@override String get allowanceCategory => 'فئة البدل';
@override String get effectiveTo => 'ساري حتى';
@override String get pleaseEnterNumberOfDays => 'يرجى إدخال عدد الأيام';
@override String get numberOfDaysCannotBeNegative => 'لا يمكن أن يكون عدد الأيام سالبًا';
@override String get enteredDaysCannotExceedAllocated => 'الأيام المدخلة لا يمكن أن تتجاوز الأيام المخصصة';
@override String get pleaseEnterValidNumber => 'يرجى إدخال رقم صالح';

}
