import 'app_localizations.dart';

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get welcome => '欢迎使用 DigiXpense';

  @override
  String get login => '登录';

  @override
  String get setting => '设置';
  @override
  String get firstName => '名字';
  @override
  String get middleName => '中间名';
  @override
  String get lastName => '姓氏';
  @override
  String get personalMailId => '个人邮箱';
  @override
  String get phoneNumber => '电话号码';
  @override
  String get gender => '性别';
  @override
  String get permanentAddress => '永久地址';
  @override
  String get street => '街道';
  @override
  String get city => '城市';
  @override
  String get searchCountry => '搜索国家';
  @override
  String get zipCode => '邮政编码';
  @override
  String get searchState => '搜索州/省';
  @override
  String get sameAsPermanentAddress => '与永久地址相同';
  @override
  String get presentAddress => '当前地址';
  @override
  String get localizationPreferences => '本地化和偏好设置';
  @override
  String get timeZone => '时区';
  @override
  String get defaultPayment => '默认支付方式';
  @override
  String get defaultCurrency => '默认货币';
  @override
  String get selectLocale => '选择语言';
  @override
  String get pleasePickLanguage => '请选择一种语言';
  @override
  String get defaultLanguage => '默认语言';
  @override
  String get selectDateFormat => '选择日期格式';
  @override
  String get cancel => '取消';
  @override
  String get submit => '提交';
  @override
  String get emailSettings => '电子邮件设置';
  @override
  String get enterEmail => '输入电子邮件';
  @override
  String get invalidEmails => '一个或多个电子邮件无效';
  @override
  String get enterPhoneNumber => '请输入电话号码';
  @override
  String get phoneNumberDigitsOnly => '电话号码必须为10位数字';
  @override
  String get save => '保存';
  @override
  String get dashboard => '仪表板';

  @override
  String get myDashboard => '我的仪表板';
  @override
  String get personalInformation => '个人资料';
  @override
  String get personalDetails => '个人信息';
 @override
  String get punchInOut => '打卡/签退';
  
  @override
  String get punchInOutList => '打卡记录';
  
  @override
  String get myTeamAttendance => '我的团队考勤';
  
  @override
  String get timesheets => '时间表';
  
  @override
  String get myTeamTimesheets => '我的团队时间表';
  
  @override
  String get payroll => '工资单';
  
  @override
  String get myPayslips => '我的工资条';
  
  @override
  String get allPayslips => '所有工资条';
    @override
  String get leaveCancellation => '请假取消';
  @override
  String get fullyCancel => '完全取消';
  
  @override
  String get partialCancel => '部分取消';
  
  @override
  String get cardView => '卡片视图';
  
  @override
  String get calendarView => '日历视图';
  
  @override
  String get month => '月';
  
  @override
  String get week => '周';
  @override String get wouldYouLikeToPunch => '您要打卡吗？';
  
  @override String get punchOut => '签退';
  
  @override String get punchIn => '打卡';
  
  @override String get status => '状态';
  
  @override String get lastSession => '上次会话';
  
  @override String get lastIn => '上次打卡';
  
  @override String get lastOut => '上次签退';
  
  @override String get totalTime => '总时间';
  
  @override String get selfieVerification => '自拍验证';
  
  @override String get retake => '重拍';
  
  @override String get currentLocation => '当前位置';
  
  @override String get myLocation => '我的位置';
  
  @override String get loading => '加载中...';
  
  @override String get fetchingLocation => '获取位置中...';
  
  @override String get locationPermissionDenied => '位置权限被拒绝';
  
  @override String get failedToFetchLocation => '获取位置失败';
  
  @override String get cameraPermissionDenied => '相机权限被拒绝';
  
  @override String get networkError => '网络错误';
  
  @override String get punchFailed => '打卡失败，请重试。';
  
  @override String get punchedInSuccessfully => '打卡成功！';
  
  @override String get punchedOutSuccessfully => '签退成功！';
  
  @override String get noPreviousSession => '无上次会话';
  
  @override String get locationNotAvailable => '位置不可用';
  
  @override String get takeSelfie => '拍照';
  
  @override String get selfiePlaceholder => '添加自拍';
  @override
  String get day => '日';
  @override
  String get myTimesheets => '我的时间表';
  @override
  String get board => '公告板';
  @override
  String get approvedExpensesTotal => '已批准的费用（总计）';

  @override
  String get expensesInProgressTotal => '进行中的费用（总计）';

  @override
  String get approvedAdvancesTotal => '已批准的预付款（总计）';

  @override
  String get advancesInProgressTotal => '进行中的预付款（总计）';
  @override
  String get expense => '费用';

  @override
  String get approvals => '审批';

  @override
  String get mail => '邮件';
  @override
  String get seeMore => '查看更多 ▼';

  @override
  String get seeLess => '收起 ▲';
  @override
String get myExpenseTrends => '我的费用趋势';

@override
String get myExpenseAmountByApprovalStatus => '我的费用金额（按审批状态）';

@override
String get mySettlementStatus => '我的结算状态';

@override
String get myExpensesByProject => '我的费用（按项目）';

@override
String get totalExpensesByCategory => '按类别的总费用';

@override
String get cashAdvance => '预付款';
@override
String get myExpenses => '我的费用';

@override
String get myTeamExpenses => '我的团队费用';

@override
String get pendingApprovals => '待审批';

@override
String get unProcessed => '未处理';

@override
String get myCashAdvances => '我的预付款';

@override
String get myTeamCashAdvances => '我的团队预付款';

@override
String get emailHub => '邮件中心';

@override
String get approvalHub => '审批中心';

@override
String get reports => '报表';

@override
String get expensesReports => '费用报表';

@override
String get settings => '设置';

@override
String get help => '帮助';

@override
String get logout => '退出';

@override
String get hello => '你好';

@override
String get hiThere => '嗨';

@override
String get welcomeBack => '欢迎回来';
 @override
  String get delete => '删除';
  @override
  String get unReported => '未报销';
  @override
  String get approved => '已批准';
  @override
  String get cancelled => '已取消';
  @override
  String get rejected => '已拒绝';
  @override
  String get inProcess => '处理中';
  @override
  String get all => '全部';
  @override
  String get expenseDashboard => '费用仪表板';
  @override
  String get searchExpenses => '搜索费用...';
  @override
  String get addExpense => '添加费用';
  @override
  String get addPerDiem => '添加日津贴';
  @override
  String get addCashAdvanceReturn => '添加预付款结算';
  @override
  String get addMileage => '添加里程';
  @override
  String get allExpenses => '所有费用';
  @override
  String get generalExpenses => '一般费用';
  @override
  String get perDiem => '日津贴';
  @override
  String get cashAdvanceReturn => '预付款结算';
  @override
  String get mileage => '里程';
  @override
  String get noExpensesFound => '未找到费用';
 
  @override
  String get view => '查看';
  @override
  String get unknownExpenseType => '未知费用类型:';
  @override String get generalExpenseForm => '一般费用表单';
@override String get projectId => '项目编号';
@override String get projectName => '项目名称';
@override String get pleaseSelectProject => '请选择一个项目';
@override String get taxGroup => '税组';
@override String get pleaseSelectTaxGroup => '请选择一个税组';
@override String get taxAmountRequired => '需要填写税额';
@override String get paidFor => '支付用于';
@override String get pleaseSelectCategory => '请选择一个类别';
@override String get unit => '单位';
@override String get uomId => '计量单位编号';
@override String get uomName => '计量单位名称';
@override String get unitAmount => '单价金额';
@override String get unitAmountRequired => '需要填写单价金额';
@override String get quantity => '数量';
@override String get quantityRequired => '需要填写数量';
@override String get lineAmount => '行金额';
@override String get lineAmountInInr => '行金额（印度卢比）';
@override String get accountDistribution => '账户分配';
@override String get totalAmount => '总金额:';
@override String get comments => '备注';
@override String get remove => '删除';
@override String get itemize => '逐项列出';
@override String get isReimbursable => '可报销';
@override String get isBillable => '可计费';
@override String get finish => '完成';
@override String get next => '下一步';
@override String get pleaseSelectRequestDate => '请选择申请日期';
@override String get requestDate => '申请日期';
@override String get selectDate => '选择日期';
@override String get paidTo => '支付给';
@override String get selectFromMerchantList => '从商家列表中选择';
@override String get enterMerchantManually => '找不到商家？手动输入';
@override String get selectMerchant => '选择商家';
@override String get merchantName => '商家名称';
@override String get merchantId => '商家编号';
@override String get enterMerchantName => '输入商家名称';
@override String get fieldRequired => '此字段为必填项';
@override String get cashAdvanceRequest => '现金预支申请';
@override String get pleaseSelectCashAdvanceField => '请选择一个现金预支字段';
@override String get requestId => '申请编号';
@override String get paidWith => '支付方式';
@override String get clear => '清除';
@override String get zoomIn => '放大';
@override String get zoomOut => '缩小';
@override String get edit => '编辑';
@override String get tapToUploadDocs => '点击上传文件';
@override String get capture => '拍摄';
@override String get upload => '上传';
@override String get paidAmount => '支付金额';
@override String get paidAmountRequired => '需要填写支付金额';
@override String get enterValidAmount => '请输入有效的金额';
@override String get currency => '货币 *';
@override String get pleaseSelectCurrency => '请选择货币';
@override String get rate => '汇率';
@override String get rateRequired => '需要填写汇率';
@override String get enterValidRate => '请输入有效的汇率';
@override String get lightheme => '浅色主题颜色';
@override String get darktheme => '深色主题颜色';
@override String get notifications => '通知';
@override String get unread => '未读';
@override
String get exitWarning => '您将丢失所有未保存的数据。是否要退出？';
@override
String get duplicateReceiptWarning => '此收据似乎是重复的。您要继续吗？';

@override
String get continueText => '继续';

@override
String get duplicateReceiptDetected => '检测到重复收据';

@override
String get extractingReceipt => '我们正在提取您的收据';
@override
String get pleaseWait => '请稍候...';

@override
String get exitForm => '退出表单';
@override String get allNotifications => '所有通知';
@override String get amountInInr => '金额（印度卢比）';
@override String get policyViolations => '政策违规';
@override String get checkPolicies => '检查政策';
@override String get policy1001 => '政策 1001';
@override String get expenseAmountUnderLimit => '费用金额低于限额';
@override String get receiptRequiredAmount => '需要收据的金额：所有费用都必须有收据';
@override String get descriptionMandatory => '如果管理员已将描述设置为所有费用的必填项';
@override String get expiredPolicy => '过期的费用被视为违反政策';
@override String get taxId => '税号';
@override String get back => '返回';
@override String get taxAmount => '税额';
@override String get cropImage => '裁剪图片';
@override String get referenceId => '参考编号';
@override String get pleaseSelectMerchant => '请选择商户';
@override String get pleaseEnterMerchantName => '请输入商户名称';
@override String get createPerDiem => '创建每日津贴';
@override String get editPerDiem => '编辑每日津贴';
@override String get viewPerDiem => '查看每日津贴';
@override String get perDiemDetails => '每日津贴详情';
@override String get expenseId => '费用编号';
@override String get employeeId => '员工编号';
@override String get reliever => '代理人';
@override String get department => '部门';
@override String get dates => '日期';
@override String get notifyingUsers => '通知用户';
@override String get contactNumber => '联系电话';
@override String get availabilityDuringLeave => '休假期间可用性';
@override String get availability => '可用性';
@override String get outOfOfficeMessage => '外出自动回复';
@override String get notifyHR => '通知人力资源';
@override String get notifyTeamMembers => '通知团队成员';
@override String get paidLeave => '带薪休假';
@override String get totalDays => '总天数';
@override String get saveAsDraft => '保存为草稿';
@override String get editLeaveRequest => '编辑请假申请';
@override String get newLeaveRequest => '新建请假申请';
@override
String get newCreateLeaveRequest => '创建请假申请';

@override String get leaveRequisitionId => '请假申请编号';
@override String get delegatedAuthority => '代理人/代理权限';
@override String get locationDuringLeave => '休假期间地点';
@override String get availableForUrgentMatters => '紧急事项可联系';
@override String get notAvailable => '不可用';
@override String get dayType => '天类型';
@override String get fullDay => '全天';
@override String get firstHalf => '上半天';
@override String get secondHalf => '下半天';
@override String get myTeamLeaveDashboard => '我的团队请假看板';
@override String get noEventsFor => '无事件：';
@override String get duration => '时长';

@override String get mon => '周一';
@override String get tue => '周二';
@override String get wed => '周三';
@override String get thu => '周四';
@override String get fri => '周五';
@override String get sat => '周六';
@override String get sun => '周日';

@override String get noLeaveData => '暂无请假数据';
@override String get remaining => '剩余';
@override String get outOf => '中的';
@override String get balance => '余额';
@override String get leaveRequisition => '请假申请';
@override String get myLeave => '我的请假';
@override String get myTeamLeave => '我的团队请假';
@override String get myTeamLeaveCancellation => '团队请假取消';
@override
String get addLeaveRequest => '新增请假申请';

@override
String get ofLeave => '的请假';
@override
String get appliedDate => '申请日期';

@override
String get total => '总计';

@override
String get uploadFileOrDragDrop => '上传文件或拖放';

@override
String get uploadAttachments => '附件';


@override
String get days => '天数';

  @override
  String get leaveCode => '请假代码';
@override String get location => '地点';
@override String get country => '国家';
@override String get pleaseSelectLocation => '请选择地点';
@override String get close => '关闭';


@override String get fromDate => '开始日期';
@override String get toDate => '结束日期';
@override String get noOfDays => '天数';
@override String get user => '用户';
@override String get userName => '用户名';
@override String get userId => '用户编号';
@override String get code => '代码';
@override String get name => '名称';
@override String get symbol => '符号';
@override String get editCashAdvanceReturn => '编辑现金预付款退还';
@override String get viewCashAdvanceReturn => '查看现金预付款退还';
@override String get receiptDetails => '收据详情';
@override String get returnDate => '归还日期';
@override String get paymentName => '付款名称';
@override String get paymentId => '付款编号';
  @override String get item => '项目';
@override String get categoryName => '类别名称';
@override String get categoryId => '类别编号';
@override String get receiptDate => '收据日期';
@override String get pleaseSelectUnit => '请选择一个单位';
@override String get paymentInfo => '付款信息';

@override String get expenseDetails => '费用详情';
@override String get cashAdvanceReturnForm => '现金预支返还表单';
@override String get mileageRegistration => '里程登记';
@override String get mileageDetails => '里程详情';
@override String get mileageDate => '里程日期';
@override String get mileageType => '里程类型';
@override String get vehicle => '车辆';
@override String get confirm => '确认';
@override String get fillAllTripLocations => '请在提交前填写所有行程位置。';
@override String get turnOffRoundTrip => '关闭往返行程';
@override String get endTrip => '结束行程';
@override String get startTrip => '开始行程';
@override String get addTrip => '添加行程';
@override String get roundTrip => '往返行程';
@override String get totalDistance => '总距离';
@override String get editExpenseApproval => '编辑费用审批';
@override String get viewExpenseApproval => '查看费用审批';
@override String get deleteConfirmation => '您确定要删除吗？';
@override String get deleteWarning => '此操作无法撤销。';
@override String get unProcessedExpense => '未处理的费用';
@override String get cashAdvanceRequestForm => '现金预支申请表';
@override String get requestedPercentage => '申请百分比';
@override String get unitEstimatedAmount => '单位预估金额';
@override String get unitAmountIsRequired => '单位金额为必填项';
@override String get cashAdvanceRequisitionId => '现金预支申请编号';
@override String get totalEstimatedAmountInInr => '预估总金额 (INR)';
@override String get totalEstimatedAmountIn => '预估总金额';
@override String get search => '搜索';
@override String get businessJustification => '业务理由';
@override String get id => '编号';
@override
String get employeeName => '员工姓名';
@override
String get justification => '理由';
@override
String get justificationRequired => '需要说明理由';

@override
String get enterJustification => '输入说明理由';

@override
String get pleaseEnterJustification => '请输入说明理由';

@override
String get somethingWentWrong => '出现问题：';

@override String get paidAmountExceedsMaxPercentage => '支付金额超过允许的最大百分比';
  @override String get totalRequestedAmount => '申请总金额';
@override String get pdfViewerNotFound => '未找到 PDF 查看器';
@override String get noAppToViewPdf => '没有可用于查看 PDF 文件的应用。请安装 PDF 阅读器应用。';
@override String get ok => '确定';
@override String get getPdfReader => '获取 PDF 阅读器';
@override String get preview => '预览';
@override String get processed => '已处理';
@override String get from => '来自:';
@override String get attachments => '附件';
@override String get noEmailsFound => '未找到电子邮件'; 
@override String get rejectEmail => '拒绝邮件';
@override String get reasonForRejection => '拒绝原因';
@override String get emailRejectedSuccessfully => '邮件已成功拒绝';
@override String get errorRejectingEmail => '拒绝邮件时出错：';
@override String get editReport => '编辑报告';
@override String get viewReport => '查看报告';
@override String get createReport => '创建报告';
@override String get reportName => '报告名称';
@override String get enterReportTitle => '输入报告标题';
@override String get functionalArea => '职能领域';
@override String get expenseRequisition => '费用申请';
@override String get cashAdvanceRequisition => '预付款申请';
@override String get dataset => '数据集';
@override String get unknownDataset => '未知数据集';
@override String get selectDataset => '选择数据集';
@override String get description => '描述';
@override String get addShortDescription => '添加简短描述（可选）';
@override String get tags => '标签';
@override String get enterTags => '输入标签';
@override String get applicableFor => '适用于';
@override String get selectAudience => '选择受众';
@override String get filterRule => '筛选规则';
@override String get addGroup => '添加组';
@override String get group => '组';
@override String get removeGroup => '删除组';
@override String get addRuleToGroup => '向此组添加规则';
@override String get availableColumnsHeader => '可用列（表头）';
@override String get availableColumnsLines => '可用列（行）';
@override String get noColumnsAvailable => '没有可供选择的列';
@override String get table => '表';
@override String get column => '列';
@override String get condition => '条件';
@override String get enterValueToMatch => '输入匹配值';
@override String get enterStartingValue => '输入起始值';
@override String get to => '到';
@override String get enterEndingValue => '输入结束值';
@override String get removeRule => '删除规则';
@override String get or => '或';
@override String get and => '和'; 
@override String get value => '值';
@override String get addReport => '添加报告';
@override String get noReportFound => '未找到报告';
@override String get reportAvailability => '报告可用性';
@override String get generateReport => '生成报告';
@override String get export => '导出';
@override String get applyFilters => '应用筛选条件';
@override String get noDataFound => '未找到数据';
@override String get totalRejectedAmount => '被拒绝的总金额';
@override String get lastSettlementDate => '最后结算日期';
@override String get basicFiltration => '基础筛选';
@override String get advancedFiltering => '高级筛选';
@override String get groupIsEmpty => '组为空。请添加规则或删除该组。';
@override String get pleaseSelectTableForRule => '请选择组中的规则表';
@override String get pleaseSelectColumnForRule => '请选择组中的规则列';
@override String get pleaseSelectConditionForRule => '请选择组中的规则条件';
@override String get pleaseEnterValueForRule => '请输入规则的值';
@override String get pleaseEnterFromToValuesForBetween => '请为规则中的“介于”条件输入“从”和“到”的值';
@override String get expenseReport => '费用报告';
@override String get step => '步骤';
@override String get previous => '上一步';
@override String get functionalEntity => '功能实体';
@override String get selectFunctionalEntity => '选择功能实体';
@override String get sortBy => '排序依据';
@override String get selectSortField => '选择排序字段';
@override String get sortOrder => '排序顺序';
@override String get selectOrder => '选择顺序';
@override String get advancedFiltration => '高级筛选';
@override String get addNewGroup => '添加新组';
@override String get chooseTablesToViewInReport => '选择要在报告中查看的表';
@override String get transData => '交易数据';
@override String get documentAttachments => '附件';
@override String get accountingDistributions => '会计分配';
@override String get expenseCategoryCustomFields => '费用类别自定义字段';
@override String get transCustomFieldsValues => '交易自定义字段值';
@override String get headerCustomFieldsValues => '表头自定义字段值';
@override String get activityLog => '活动日志';
@override String get workflowHistory => '工作流历史';
@override String get assignUsers => '分配用户';
@override String get availableUsers => '可用用户';
@override String get moveAll => '移动全部';
@override String get moveSelected => '移动所选';
@override String get saveReport => '保存报告';
@override String get pleaseAssignAnyUser => '请分配任意用户';
@override String get print => '打印';
@override String get printAll => '打印全部';
@override String get totalAmountTrans => '总交易金额';
@override String get totalAmountReporting => '总报告金额';
@override String get approvalStatus => '审批状态';
@override String get expenseType => '费用类型';
@override String get expenseStatus => '费用状态';
@override String get currencyCode => '货币代码';
@override String get reportingCurrency => '报告货币';
@override String get source => '来源';
@override String get expenseTrans => '费用交易';
@override String get lineNumber => '行号';
@override String get expenseCategoryId => '费用类别 ID';
@override String get unitPriceTrans => '单价';
@override String get lineAmountTrans => '行金额';
@override String get type => '类型';
@override String get format => '格式';
@override String get errorLoadingImage => '加载图像错误';
@override String get pdfDocument => 'PDF 文件';
@override String get totalTransAmount => '总交易金额';
@override String get noPreviewAvailable => '没有可用的预览';
@override String get filterations => '筛选';
@override String get generalSettings => '常规设置';
@override String get field => '字段';
@override String get filteredBy => '筛选条件';
@override String get pleaseFillAllRequiredFields => '请填写所有必填字段';
@override String get generalExpense => '一般费用';
@override
  String get skip => '跳过';

@override
  String get askQuestionPrompt => "关于您的数据提问…";
  @override
  String get tryAsking => "尝试提问：";
  @override
  String get aiAnalytics => "AI 分析";
  @override String get totalHours => '总小时数';
  @override String get transactionId => '交易ID';
  @override String get punchInTime => '打卡时间';
  @override String get punchOutTime => '签退时间';
  @override String get totalDuration => '总时长';
  @override String get captureType => '捕获类型';
  @override String get punchInGeofenceId => '打卡地理围栏ID';
  @override String get punchOutGeofenceId => '签退地理围栏ID';
  @override String get isRegularized => '是否已调整';
  @override String get punchInLocation => '打卡位置';
   @override String get myAttendanceList => '我的考勤列表';
  @override String get punchOutLocation => '签退位置';
  @override String get viewTeamMemberAttendance => '查看团队成员考勤';
  @override String get viewAttendanceTransaction => '查看考勤交易';
  @override
  String get requestError => "抱歉，无法处理您的请求。请重试。";
  @override
  String get expenseDistribution => "费用分配";
  @override
  String get breakdownHeader => "以下是详细信息：";
  @override
  String get aiAnalyticsWelcome => "欢迎使用 AI 分析！我可以帮助您分析费用数据。请随意提问！";
  @override
  String get selectDimensions => '选择维度';

  @override
  String get percentage => '百分比 *';

  @override
  String get amount => '金额';

  @override
  String get report => '报表';

  @override
  String get addSplit => '添加分摊';
@override
String get timezoneName => '时区名称';

@override
String get timezoneCode => '时区代码';

@override
String get timezoneId => '时区编号';

@override
String get languageName => '语言名称';

@override
String get languageId => '语言编号';

  @override
  String totalPercentageMustBe100(double current) =>
      '总百分比必须等于100%。当前: ${current.toStringAsFixed(2)}%';
@override String get totalAmountInInr => '总金额 (INR)';
@override String get purpose => '用途';
@override String get trackingHistory => '跟踪历史';
@override String get noHistoryMessage => '此费用没有历史记录。请考虑提交以供审批。';
@override String get update => '更新';
@override String get updateAndAccept => '更新并接受';
@override String get reject => '拒绝';
@override String get resubmit => '重新提交';
@override String get approve => '批准';
@override String get escalate => '升级';
@override String get action => '操作';
@override String get selectUser => '选择用户';
@override String get enterCommentHere => '在此输入您的评论';
@override String get commentRequired => '评论为必填项';
@override String get submittedOn => '提交时间';
@override String get allocationSettings => '分配设置';
@override String get noAllocationDataMessage => '所选地点没有分配数据。请尝试其他地点。';
@override String get effectiveFrom => '生效日期';
@override String get allowanceCategory => '津贴类别';
@override String get effectiveTo => '截止日期';
@override String get pleaseEnterNumberOfDays => '请输入天数';
@override String get numberOfDaysCannotBeNegative => '天数不能为负数';
@override String get enteredDaysCannotExceedAllocated => '输入的天数不能超过分配的天数';
@override String get pleaseEnterValidNumber => '请输入有效数字';
@override String get boardDashboard => '看板仪表板';
  @override String get createBoard => '创建看板';
  @override String get boardName => '看板名称';
  @override String get boardTemplate => '看板模板';
  @override String get referenceName => '参考名称';
  @override String get boardTaskDetails => '看板任务详情';
  @override String get taskName => '任务名称';
  @override String get enterTaskName => '输入任务名称';
  @override String get selectTags => '选择标签';
  @override String get tagId => '标签ID';
  @override String get tagName => '标签名称';
  @override String get selectUsers => '选择用户';
  @override String get estimatedHours => '预计工时';
  @override String get cardType => '卡片类型';
  @override String get priority => '优先级';
  @override String get low => '低';
  @override String get high => '高';
  @override String get medium => '中';
  @override String get urgent => '紧急';
  @override String get actualHours => '实际工时';
  @override String get version => '版本';
  @override String get parentTask => '父任务';
  @override String get taskId => '任务ID';
  @override String get selectDependency => '选择依赖';
  @override String get checklist => '检查清单';
  @override String get addItem => '添加项目';
  @override String get showInCard => '在卡片中显示';
  @override String get enterNotes => '输入备注';
  @override String get addAttachment => '添加附件';
  @override String get posting => '正在发布...';
  @override String get comment => '评论';
  @override String get noCommentsYet => '暂无评论';
  @override String get grid => '网格';
  @override String get boardSettings => '看板设置';
  @override String get addShelf => '添加列';
  @override String get addTask => '添加任务';
  @override String get noTasksFound => '未找到任务';
  @override String get deleteTask => '删除任务';
  @override String get noDueDate => '无截止日期';
  @override String get shelfName => '列名称';
  @override String get searchTasksUsersTags => '搜索任务、用户、标签...';
  @override String get assigned => '已分配';
  @override String get editShelf => '编辑列';
  @override String get areYouSureDeleteTask => '确定要删除此任务吗？';
  @override String get dueDate => '截止日期';
  @override String get addBoardMembers => '添加看板成员';
   @override String get visibilityOfYourBoard => '看板可见性';
  @override String get public => '公开';
  @override String get visibleToEveryone => '对所有人可见';
  @override String get private => '私有';
  @override String get onlySelectedUsers => '仅选中的用户可见';
  @override String get enterBoardName => '输入看板名称';
  @override String get boardNameIsRequired => '看板名称是必填项';
  @override String get selectTemplate => '选择模板';
  @override String get pleaseSelectATemplate => '请选择一个模板';
  @override String get branchEmployees => '分支员工';
@override String get departmentEmployees => '部门员工';
@override String get viewType => '视图类型';
@override String get leaveFullCancellation => '全部请假取消';
@override String get reasonForCancellation => '取消原因';
@override String get pleaseEnterCancellationReason => '请输入取消原因';
@override String get leavePartialCancellation => '部分请假取消';
@override
String get myLeaveCancellations => '我的请假取消';
  @override
String get timeDetails => '时间详情';
  @override String get templateIsRequired => '模板是必填项';
  @override String get selectGroups => '选择群组';
  @override String get areYouSureDeleteBoard => '确定要删除此看板吗？';
  @override String get thisActionCannotBeUndone => '此操作无法撤销。';
  @override String get deleteBoard => '删除看板';
   @override String get boardOwnerName => '看板所有者名称';
  @override String get defaultSortingOrder => '默认排序顺序';
  @override String get byAssignee => '按负责人';
  @override String get enableTimeTracking => '启用时间跟踪';
  @override String get referenceType => '参考类型';
  @override String get boardTheme => '看板主题';
  @override String get dark => '深色';
  @override String get light => '浅色';
  @override String get systemDefault => '系统默认';
  @override String get backgroundImage => '背景图片';
  @override String get url => 'URL';
  @override String get fileUpload => '文件上传';
  @override String get imageUrl => '图片URL';
  @override String get uploadImage => '上传图片';
  @override String get removeMemberFromBoard => '从看板中移除成员？';
   @override String get members => '成员';
@override String get sendToMail => '发送到邮箱';
@override String get send => '发送';
@override String get download => '下载';
@override String get payslipsNotAvailable => '没有可用的工资单';
@override String get tableView => '表格视图';
@override String get timeTracker => '时间跟踪';
@override String get start => '开始';
@override String get pause => '暂停';
@override String get resume => '继续';
@override String get complete => '完成';
@override String get generateTimeSheet => '生成工时表';
@override String get generateAndSubmit => '生成并提交';
@override String get noTimeRunsFound => '未找到记录';
@override String get active => '进行中';
@override String get runId => '运行ID';
@override String get segment => '段';
@override String get timeRunId => '时间运行ID';
@override String get sequence => '序号';
@override String get end => '结束';
@override String get noEventsFound => '未找到事件';
@override String get event => '事件';
@override String get occurred => '发生';
@override String get periodType => '周期类型';
@override String get periodTypeIsRequired => '周期类型为必填项';
@override String get timeSheetRequestForm => '工时表申请表';
@override String get dateRange => '日期范围';
@override String get lineItem => '条目';
@override String get addLine => '添加行';
@override String get addTimer => '添加计时器';
@override String get timeSheetPendingApprovals => '待审批的工时表';
@override String get employees => '员工';
@override String get employeeGroups => '员工组';
@override String get timesheetRequisitionId => '工时表申请ID';
@override String get areaName => '区域名称';
@override String get eventType => '事件类型';
@override String get plannedStartDate => '计划开始日期';
@override String get plannedEndDate => '计划结束日期';
@override String get actualStartDate => '实际开始日期';
@override String get actualEndDate => '实际结束日期';
@override String get addTimeSheets => '添加工时表';
@override String get started => '开始';
@override String get ended => '结束';
@override String get eventTypeOccurred => '事件类型';
@override String get details => '详情';
@override String get viewDetails => '查看详情';
@override String get segmentId => '段ID';
@override String get segmentSequence => '段序号';
@override String get startTime => '开始时间';
@override String get endTime => '结束时间';
@override String get durationInHours => '持续时间（小时）';
@override String get endEvent => '结束事件';
@override String get updateDetails => '更新详情';
@override String get editSegment => '编辑段';

}
