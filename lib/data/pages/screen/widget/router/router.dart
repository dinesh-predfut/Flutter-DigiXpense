// lib/presentation/routes/app_routes.dart
import 'dart:io';

import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/pages/AI%20Analytics/aiAnalytics.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/GeneralExpense/createForm.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/GeneralExpense/viewGeneralExpense.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/Mileage/mileageExpenseForm.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/Mileage/mileageExpenseFormstart.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/Mileage/viewAndEditMileage.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/Pending%20Approval/approvalDashboard.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/Pending%20Approval/approvalPendingEdit.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/PerDiem/perDiemCreateform.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/Reports/expenseReportPrintPage.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/Reports/reportsdashboard.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/Unprocessed_Expense/viewUnProcessExpense.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/unProcessed.dart';
import 'package:digi_xpense/data/pages/screen/ALl_Expense_Screens/cashAdvanceReturn/expensecashAdvanceReturnForm.dart';
import 'package:digi_xpense/data/pages/screen/CashAdvanceRequest/MyTeamCashAdvance/myTeamCashAdvanseDashboard.dart';
import 'package:digi_xpense/data/pages/screen/CashAdvanceRequest/cashAdvanceReturnForm.dart';
import 'package:digi_xpense/data/pages/screen/Dashboard_Screen/DashboardItemsByrole/spenders.dart' show SpendersDashboardPage;
import 'package:digi_xpense/data/pages/screen/Leave_Section/My_Leave/Leave_Approvals/leaveApprovals.dart' show PendingApprovalsLeaveDashboard;
import 'package:digi_xpense/data/pages/screen/Leave_Section/My_Leave/Leave_Cancellation/leave_Cancelation_Dashboard.dart';
import 'package:digi_xpense/data/pages/screen/Leave_Section/My_Leave/My_Teams_Leave/my_Team_dashboard_leave.dart';
import 'package:digi_xpense/data/pages/screen/Leave_Section/My_Leave/dashboard_leave.dart';
import 'package:digi_xpense/data/pages/screen/Leave_Section/My_Leave/leaveCalenderView.dart' show CalendarPage;
import 'package:digi_xpense/data/pages/screen/Leave_Section/My_Leave/view_CreateLeave.dart';
import 'package:digi_xpense/data/pages/screen/Notification/notification.dart';
import 'package:digi_xpense/data/pages/screen/Payroll/paySlipDashboard.dart';
import 'package:digi_xpense/data/pages/screen/Profile/personalDetail.dart';
import 'package:digi_xpense/data/pages/screen/Task_Board/addmoreetailsTask.dart';
import 'package:digi_xpense/data/pages/screen/Task_Board/boardDashboard.dart';
import 'package:digi_xpense/data/pages/screen/Task_Board/boardList.dart' show KanbanBoardPage, KanbanBoardScreen;
import 'package:digi_xpense/data/pages/screen/Task_Board/view-Board.dart';
import 'package:digi_xpense/data/pages/screen/TimeSheet/createViewTimeSheet.dart';
import 'package:digi_xpense/data/pages/screen/TimeSheet/timesheetDashboard.dart';
import 'package:digi_xpense/data/pages/screen/landingLogo/entryLogoScree.dart';
import 'package:flutter/material.dart';
import 'package:digi_xpense/core/comman/navigationBar.dart';
import 'package:digi_xpense/data/pages/screen/Authentication/forgetPassword.dart';
import 'package:digi_xpense/data/pages/screen/Authentication/login.dart';
import 'package:digi_xpense/data/pages/screen/Dashboard_Screen/dashboard_Main.dart';
import 'package:digi_xpense/data/pages/screen/Profile/changeLanguage.dart';
import '../../../ApprovalHub/ApprovalPages/hubMileage/hubMileage_2.dart';
import '../../../ApprovalHub/approvalHubMain.dart';
import '../../../EmailHub/emailHubListing.dart';
import '../../ALl_Expense_Screens/AutoScan/autoScan.dart';
import '../../ALl_Expense_Screens/GeneralExpense/dashboard.dart';
import '../../ALl_Expense_Screens/My Team Expense/myTeamExpenseDashboard.dart';
import '../../ALl_Expense_Screens/Reports/assignUser.dart';
import '../../ALl_Expense_Screens/Reports/expenseReport.dart';
import '../../ALl_Expense_Screens/Reports/reportsCreateForm.dart';
import '../../ALl_Expense_Screens/cashAdvanceReturn/viewCashAdvanceReturn.dart';
import '../../CashAdvanceRequest/DashBoard/cashAdvanceRequestDashboard.dart';
import '../../CashAdvanceRequest/MyTeamCashAdvance/myTeamviewCashAdvanse.dart';
import '../../CashAdvanceRequest/Pending Approval/approvalDashboardCashAdvance.dart';
import '../../CashAdvanceRequest/cashAdvanceReturnEditForm.dart';
import '../../Profile/profile.dart';
import '../../landingLogo/widget.dart';

class AppRoutes {
  static const String signin = '/home';
  static const String login = '/login';
  static const String forgetPasswordurl = '/forgetPassword';
  static const String dashboard_Main = '/dashboard_Main';
    static const String spanders = '/dashboard_Main/spanders';

  static const String changesLanguage = '/profile/changesLanguage';
  static const String profile = '/profile/profileinfo';
  static const String personalInfo = '/profile/profileDetailsPage';
  static const String entryScreen = '/profile/entryLogoScreen';
  static const String generalExpense = '/expense/generalExpense';
  static const String expenseForm = '/expense/generalExpense/from';
  static const String getSpecificExpense = '/expense/getSpecificExpense/view';
    static const String unProcessExpense = '/expense/unProcessExpense/view';

  static const String getSpecificCashAdvanseView =
      '/expense/getSpecificCashAdvanseView/view';
  static const String myTeamExpenseDashboard =
      '/expense/MyTeamExpenseDashboard/Dashboard';
  static const String getSpecificExpenseApproval =
      '/expense/getSpecificExpenseApproval/view';
  static const String mileageDetailsPage = '/expense/mileageDetailsPage/view';
  static const String autoScan = '/expense/outScan/view';
  static const String perDiem = '/expense/PerDiem/create';
  static const String mileageExpense = '/expense/mileageExpense/create';
  static const String hubmileageExpense = '/expense/hubmileageExpense/create';
  static const String cashAdvanceRequestDashboard =
      '/expense/formCashAdvanceRequest/formCashAdvanceRequest';
  static const String viewCashAdvanseReturnForms =
      '/expense/viewCashAdvanseReturnForms/viewCashAdvanseReturnForms';
  static const String aIAnalyticsPage = '/page/aIAnalyticsPage/aIAnalyticsPage';
  static const String notification = '/notification';
  static const String mileageExpensefirst =
      '/expense/mileageExpense/mileageExpensefirst';
  static const String cashAdvanceReturnForms =
      '/expense/cashAdvanceReturnForm/cashAdvanceReturnForm';
  static const String formCashAdvanceRequest =
      '/expense/cashAdvanceReturnForms/cashAdvanceReturnForms';
  static const String myTeamcashAdvanceDashboard =
      '/expense/myTeamcashAdvanceDashboards/myTeamcashAdvanceDashboard';
  static const String approvalDashboard =
      '/expense/pendingApprovals/approvalDashboard';
  static const String approvalDashboardForDashboard =
      '/expense/pendingApprovals/approvalDashboardForDashboard';
  static const String unProcessed = '/expense/unProcessed/unProcessed';
  static const String approvalHubMain =
      '/expense/approvalHubMain/approvalHubMain';
  static const String reportsDashboard =
      '/expense/reportsDashboard/reportsDashboard';
  static const String reportsAssignUser =
      '/expense/reportsAssignUser/reportsAssignUser';
       static const String leaveDashboard =
      '/expense/leaveDashboard/leaveDashboard';
  static const String reportCreateScreen =
      '/expense/reportCreateScreen/reportCreateScreen';
  static const String emailHubScreen = '/expense/emailHubScreen/emailHubScreen';
  static const String reportWizardParent =
      '/expense/reportWizardParent/reportWizardParent';
       static const String expensePaginationPage =
      '/expense/reportWizardParent/reportWizardParent';
  static const String calendarView =
      '/leave/calendarView/calendarView';
       static const String myTeamsDashboard =
      '/myTeamsDashboard/myTeamsDashboard/myTeamsDashboard';
       static const String viewLeave =
      '/leave/viewLeave/viewLeave';
       static const String leavePendingApprovals =
      '/leave/leavePendingApprovals/leavePendingApprovals';
         static const String leaveCancellation =
      '/leave/leaveCancellation/leaveCancellation';
       static const String paySlipDashboard =
      '/leave/paySlipDashboard/paySlipDashboard';
       static const String boardDashboard =
      '/leave/boardDashboard/boardDashboard';
        static const String createBoard =
      '/leave/boardDashboard/createBoard';
        static const String kanbanBoardPage =
      '/leave/kanbanBoardPage/kanbanBoardPage';
           static const String taskAddDetails =
      '/leave/kanbanBoardPage/taskAddDetails';
              static const String timeSheetDashboard =
      '/leave/timeSheetDashboard/timeSheetDashboard';
      static const String timeSheetRequestPage =
      '/leave/timeSheetRequestPage/timeSheetRequestPage';
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case entryScreen:
        return MaterialPageRoute(builder: (_) => const Logo_Screen());
      case login:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case signin:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case forgetPasswordurl:
        return MaterialPageRoute(builder: (_) => const ForgetPassword());
      case changesLanguage:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
           case leaveDashboard:
        return MaterialPageRoute(builder: (_) => const LeaveDashboard());
      case personalInfo:
        return MaterialPageRoute(builder: (_) => const PersonalDetailsPage());
      case notification:
        return MaterialPageRoute(builder: (_) => const NotificationPage());
         case paySlipDashboard:
        return MaterialPageRoute(builder: (_) => const Payslip_Dashboard());
         case timeSheetDashboard:
        return MaterialPageRoute(builder: (_) => const TimeSheetDashboard());
         case timeSheetRequestPage:
        return MaterialPageRoute(builder: (_) => const TimeSheetRequestPage());
        // case taskAddDetails:
        // return MaterialPageRoute(builder: (_) => const TaskDetailsPage());
        // Your route configuration should look like this:
case kanbanBoardPage:
  final args = settings.arguments as Map<String, dynamic>?;
  
  if (args != null && args['boardId'] != null) {
    final board = args['boardId'];
    return MaterialPageRoute(
      builder: (_) => KanbanBoardScreen(boardId: board),
    );
  } else {
    // Return to previous screen or show error
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text('Board not found'),
        ),
      ),
    );
  }
      
      case cashAdvanceReturnForms:
        return MaterialPageRoute(builder: (_) => const CashAdvanceReturnForm());
          case leaveCancellation:
        return MaterialPageRoute(builder: (_) => const CancellationLeaveDashboard());
      case reportWizardParent:
        return MaterialPageRoute(builder: (_) => ReportWizardParent());
      case reportsAssignUser:
        return MaterialPageRoute(builder: (_) => const UserAssignmentScreen());
      case aIAnalyticsPage:
        return MaterialPageRoute(builder: (_) => const AIAnalyticsPage());
          case myTeamsDashboard:
        return MaterialPageRoute(builder: (_) => const MyTeamLeaveDashboard());
          case leavePendingApprovals:
        return MaterialPageRoute(builder: (_) => const PendingApprovalsLeaveDashboard());
        case boardDashboard:
        return MaterialPageRoute(builder: (_) => const BoardDashboard());
         case createBoard:
        return MaterialPageRoute(builder: (_) => const CreateEditBoardPage());
        case AppRoutes.viewLeave:

 final Map<String, dynamic>? args =
    settings.arguments as Map<String, dynamic>?;

final LeaveDetailsModel? leaveRequest =
    args != null ? args['item'] as LeaveDetailsModel? : null;

final bool readOnly = args?['readOnly'] == true;
final bool status = args?['status'] == true; // ✅ SAFE
print("StatusLeave$status");
return MaterialPageRoute(
  builder: (_) => ViewEditLeavePage(
    leaveRequest: leaveRequest,
    isReadOnly: readOnly,
    status: status,
  ),
);


      case myTeamExpenseDashboard:
        return MaterialPageRoute(
          builder: (_) => const MyTeamExpenseDashboard(),
        );
      case unProcessed:
        return MaterialPageRoute(builder: (_) => const UnProcess());
      case cashAdvanceRequestDashboard:
        return MaterialPageRoute(
          builder: (_) => const CashAdvanceRequestDashboard(),
        );
      case reportCreateScreen:
        return MaterialPageRoute(
          builder: (_) => const ReportCreateScreen(isEdit: false),
        );
      case reportsDashboard:
        return MaterialPageRoute(builder: (_) => const MyReportsDashboard());
      case myTeamcashAdvanceDashboard:
        return MaterialPageRoute(
          builder: (_) => const MyTeamCashAdvanceDashboard(),
        );
      case formCashAdvanceRequest:
        return MaterialPageRoute(
          builder: (_) => const FormCashAdvanceRequest(),
        );
      case emailHubScreen:
        return MaterialPageRoute(builder: (_) => const EmailHubScreen());
      case expensePaginationPage:
        return MaterialPageRoute(builder: (_) => const ExpensePaginationPage());
        case calendarView:
        return MaterialPageRoute(builder: (_) => const CalendarPage());
      case approvalHubMain:
        return MaterialPageRoute(builder: (_) => const ApprovalHubPage());
      case AppRoutes.viewCashAdvanseReturnForms:
        final args = settings.arguments as Map<String, dynamic>?;
                final bool readOnly = args?['readOnly'] == true;

        print("args$args");
        return MaterialPageRoute(
          builder: (_) => ViewCashAdvanseReturnForm(items: args?['item'],isReadOnly: readOnly),
        );
      case approvalDashboardForDashboard:
        return MaterialPageRoute(
          builder: (_) => const PendingApprovalDashboardforPending(),
        );

      case approvalDashboard:
        return MaterialPageRoute(
          builder: (_) => const PendingApprovalDashboard(),
        );
      case mileageDetailsPage:
        final args = settings.arguments as Map<String, dynamic>;
        final expense = args['item'] as ExpenseModelMileage;

        return MaterialPageRoute(
          builder: (_) => MileageDetailsPage(mileageId: expense),
        );
      case generalExpense:
        return MaterialPageRoute(
          builder: (_) => const GeneralExpenseDashboard(),
        );
      case perDiem:
        final args = settings.arguments as Map<String, dynamic>?;
        final bool readOnly = args?['readOnly'] == true;
        if (args != null) {
          print("argsperDiems${args['readOnly']}");
          return MaterialPageRoute(
            builder: (_) =>
                CreatePerDiemPage(item: args['item'], isReadOnly: readOnly),
          );
        } else {
          // fallback: navigate to CreatePerDiemPage without item or show error
          return MaterialPageRoute(
            builder: (_) => const CreatePerDiemPage(isReadOnly: true),
          );
        }
      case hubmileageExpense:
        final args = settings.arguments as Map<String, dynamic>;

        final bool isEditMode = args['isEditMode'] as bool? ?? false;
        final ExpenseModelMileage? mileageId =
            args['mileageId'] as ExpenseModelMileage?;

        debugPrint("✅ isEditMode: $isEditMode");
        debugPrint("✅ mileageId: $mileageId");

        return MaterialPageRoute(
          builder: (_) => HubMileageSecondFrom(
            mileageId: mileageId,
            isEditMode: isEditMode,
          ),
        );
      case mileageExpense:
        final args = settings.arguments as Map<String, dynamic>;

        final bool isEditMode = args['isEditMode'] as bool? ?? false;
        final ExpenseModelMileage? mileageId =
            args['mileageId'] as ExpenseModelMileage?;

        debugPrint("✅ isEditMode: $isEditMode");
        debugPrint("✅ mileageId: $mileageId");

        return MaterialPageRoute(
          builder: (_) => MileageRegistrationPage(
            mileageId: mileageId,
            isEditMode: isEditMode,
          ),
        );
      case AppRoutes.mileageExpensefirst:
        final args = settings.arguments as Map<String, dynamic>?;

        ExpenseModelMileage? expense;
        bool isReadOnly = false;

        if (args != null) {
          if (args.containsKey('item')) {
            expense = args['item'] as ExpenseModelMileage;
          }
        }

        return MaterialPageRoute(
          builder: (_) => MileageFirstFrom(
            mileageId: expense,
            isReadOnly: args?['isReadOnly'],
          ),
        );
      case AppRoutes.autoScan:
        final rawArgs = settings.arguments as Map;
        final args = Map<String, dynamic>.from(rawArgs);

        final File imageFile = args['imageFile'];
        final Map<String, dynamic> apiResponse = Map<String, dynamic>.from(
          args['apiResponse'],
        );

        return MaterialPageRoute(
          builder: (_) => AutoScanExpensePage(
            imageFile: imageFile,
            apiResponse: apiResponse,
          ),
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ScaffoldWithNav(
            pages: [DashboardPage(), GeneralExpenseDashboard(), LoginScreen()],
            initialIndex: 0,
          ),
        );
      case dashboard_Main:
        return MaterialPageRoute(
          builder: (_) => const ScaffoldWithNav(
            pages: [
              DashboardPage(),
              GeneralExpenseDashboard(),
              AIAnalyticsPage(),
              PersonalDetailsPage(),
            ],
          ),
        );
        case spanders:
                final args = settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(builder: (_) =>  SpendersDashboardPage(role: args["id"]));
      case expenseForm:
        return MaterialPageRoute(builder: (_) => const ExpenseCreationForm());
      case AppRoutes.getSpecificExpense:
        final args = settings.arguments as Map<String, dynamic>?; 
        print("args$args");
        return MaterialPageRoute(
          builder: (_) => ViewEditExpensePage(
            items: args?['item'],
            isReadOnly: args?['readOnly'],
          ),
        );
      case AppRoutes.getSpecificCashAdvanseView:
        final args = settings.arguments as Map<String, dynamic>?;
        print("args1${args?['readOnly']}");
        return MaterialPageRoute(
          builder: (_) => ViewCashAdvanseReturnForms(
            items: args?['item'],
            isReadOnly: args?['readOnly'],
          ),
        );
      case AppRoutes.getSpecificExpenseApproval:
        final args = settings.arguments as Map<String, dynamic>?;
        print("args$args");
        return MaterialPageRoute(
          builder: (_) => ApprovalViewEditExpensePage(
            items: args?['item'],
            isReadOnly: true,
          ),
        );
 case AppRoutes.unProcessExpense:
        final args = settings.arguments as Map<String, dynamic>?;
        print("args$args");
        return MaterialPageRoute(
          builder: (_) => UnprocessEditExpensePage(
            items: args?['item'],
            isReadOnly: args?['readOnly'],
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
