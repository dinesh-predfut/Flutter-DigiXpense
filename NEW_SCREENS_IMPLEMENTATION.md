# New Screens Implementation

This document outlines the implementation of the new screens based on the Figma designs for the DigiXpense Flutter application.

## Overview

The following screens have been implemented according to the Figma designs:

1. **Cash Advance Return** - List and detail views for cash advance returns
2. **Email Hub** - Email management with filtering and preview functionality
3. **Approval Hub** - Approval workflow management for various expense types
4. **My Team Expense** - Team expense management with summary cards
5. **My Team Cash Advance** - Team cash advance management with summary cards

## Architecture

### Global API Service

A centralized API service has been implemented to manage Bearer token authentication globally:

#### `lib/core/services/api_service.dart`
- Singleton pattern for global access
- Automatic Bearer token inclusion in all requests
- Common HTTP methods (GET, POST, PUT, DELETE, PATCH)
- Centralized error handling and response parsing

#### `lib/core/services/new_screens_api_service.dart`
- Specialized API service for the new screens
- Uses the global API service for authentication
- Implements specific endpoints for each screen's functionality

### Models

#### `lib/core/models/new_screens_models.dart`
Comprehensive models for all new screens:

- `CashAdvanceReturnModel` - Cash advance return data
- `EmailHubModel` - Email data with status tracking
- `ApprovalHubModel` - Approval workflow data
- `MyTeamExpenseModel` - Team expense data
- `MyTeamCashAdvanceModel` - Team cash advance data
- Supporting models for items, history, and policy violations

### Common Widgets

Reusable UI components for consistent design:

#### `lib/data/pages/screen/widget/`
- `common_header.dart` - Standard header with greeting
- `common_app_bar.dart` - Standard app bar
- `common_search_bar.dart` - Search functionality
- `common_filter_tabs.dart` - Filter tabs
- `common_status_badge.dart` - Status indicators
- `common_list_item_card.dart` - List item cards
- `summary_card.dart` - Summary information cards
- `common_bottom_navigation.dart` - Bottom navigation

## Screen Implementations

### 1. Cash Advance Return

**File:** `lib/data/pages/screen/CashAdvanceReturn/cash_advance_return_list_screen.dart`

**Features:**
- List view of cash advance returns
- Search functionality
- Filter by status (All, Pending, Approved, Rejected)
- Status badges with color coding
- Pull-to-refresh functionality
- Navigation to detail screens

**API Endpoints:**
- `GET /cashadvancereturnheader` - List all returns
- `GET /cashadvancereturn?ReturnId={id}` - Get specific return
- `POST /cashadvancereturn` - Create new return
- `PUT /cashadvancereturn` - Update return

### 2. Email Hub

**File:** `lib/data/pages/screen/EmailHub/email_hub_screen.dart`

**Features:**
- Email list with sender avatars
- Filter by status (All, Processed, Un-Processed, Rejected)
- Email preview panel
- Process/Reject email actions
- Search functionality
- Responsive layout with split view

**API Endpoints:**
- `GET /emails?status={status}` - List emails with optional status filter
- `POST /processemail?EmailId={id}` - Process email
- `POST /rejectemail?EmailId={id}&Reason={reason}` - Reject email

### 3. Approval Hub

**File:** `lib/data/pages/screen/ApprovalHub/approval_hub_screen.dart`

**Features:**
- Pending approvals list
- Filter by expense type (General Expense, Per Diem, Mileage, Cash Advance Return)
- Approval actions (Approve, Reject, Escalate, Skip)
- Policy violation indicators
- Approval history tracking
- Comments for actions

**API Endpoints:**
- `GET /pendingapprovals?ExpenseType={type}` - List pending approvals
- `POST /approveraction` - Perform approval actions

### 4. My Team Expense

**File:** `lib/data/pages/screen/MyTeamExpense/my_team_expense_screen.dart`

**Features:**
- Team expense summary cards
- Filter by status (All, In Process, Approved, Rejected)
- Search functionality
- Expense details navigation
- Pull-to-refresh functionality

**API Endpoints:**
- `GET /expenseheader?filter_query=CreatedBy__in_team&Status={status}` - List team expenses
- `GET /expenseregistration?ExpenseId={id}` - Get expense details
- `GET /expenseheader?summary=true` - Get summary data

### 5. My Team Cash Advance

**File:** `lib/data/pages/screen/MyTeamCashAdvance/my_team_cash_advance_screen.dart`

**Features:**
- Team cash advance summary cards
- Filter by status (All, In Process, Approved, Rejected)
- Search functionality
- Cash advance details navigation
- Pull-to-refresh functionality

**API Endpoints:**
- `GET /getcashadvanceheader?filter_query=CreatedBy__in_team&Status={status}` - List team cash advances
- `GET /cashadvance?CashAdvanceId={id}` - Get cash advance details
- `GET /getcashadvanceheader?summary=true` - Get summary data

## API Configuration

### URL Constants

**File:** `lib/core/constant/url.dart`

New API endpoints have been added:

```dart
// Cash Advance Return APIs
static const cashAdvanceReturnList = "$baseURL/api/v1/cashadvancerequisition/cashadvanceregistration/cashadvancereturnheader";
static const cashAdvanceReturnCreate = "$baseURL/api/v1/cashadvancerequisition/cashadvanceregistration/cashadvancereturn?functionalentity=CashAdvanceReturn";
static const cashAdvanceReturnGet = "$baseURL/api/v1/cashadvancerequisition/cashadvanceregistration/cashadvancereturn?";
static const cashAdvanceReturnUpdate = "$baseURL/api/v1/cashadvancerequisition/cashadvanceregistration/cashadvancereturn?functionalentity=CashAdvanceReturn";

// Email Hub APIs
static const emailHubList = "$baseURL/api/v1/emailhub/emailhub/emails?";
static const emailHubProcess = "$baseURL/api/v1/emailhub/emailhub/processemail?";
static const emailHubReject = "$baseURL/api/v1/emailhub/emailhub/rejectemail?";

// My Team Expense APIs
static const myTeamExpenseList = "$baseURL/api/v1/expenseregistration/expenseregistration/expenseheader?filter_query=EXPExpenseHeader.CreatedBy__in_team&";
static const myTeamExpenseGet = "$baseURL/api/v1/expenseregistration/expenseregistration/expenseregistration?";

// My Team Cash Advance APIs
static const myTeamCashAdvanceList = "$baseURL/api/v1/cashadvancerequisition/cashadvanceregistration/getcashadvanceheader?filter_query=CSHCashAdvHeader.CreatedBy__in_team&";
static const myTeamCashAdvanceGet = "$baseURL/api/v1/cashadvancerequisition/cashadvanceregistration/cashadvance?";
```

### Bearer Token Management

The Bearer token is now managed globally through the `Params.userToken` static variable and automatically included in all API requests via the `ApiService` class.

## Design System

### Colors
- Primary: `#6A4C93` (Purple)
- Success: `#4CAF50` (Green)
- Error: `#F44336` (Red)
- Warning: `#FF9800` (Orange)
- Neutral: `#9E9E9E` (Grey)

### Typography
- Headers: 24px, Bold
- Subheaders: 18px, Medium
- Body: 14px, Normal
- Captions: 12px, Normal

### Spacing
- Standard padding: 16px
- Card margin: 12px
- Section spacing: 20px

## Usage

### Adding New Screens

1. Create the screen file in the appropriate directory
2. Import the common widgets
3. Use the `NewScreensApiService` for API calls
4. Follow the established design patterns

### Example Screen Structure

```dart
class ExampleScreen extends StatefulWidget {
  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  final NewScreensApiService _apiService = NewScreensApiService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Screen Title'),
      body: Column(
        children: [
          CommonHeader(title: 'Screen Title'),
          CommonSearchBar(
            controller: _searchController,
            hintText: 'Search...',
            onChanged: _searchItems,
          ),
          CommonFilterTabs(
            filterOptions: ['All', 'Option1', 'Option2'],
            selectedFilter: _selectedFilter,
            onFilterChanged: _filterItems,
          ),
          // Screen-specific content
        ],
      ),
    );
  }
}
```

## Error Handling

All API calls include comprehensive error handling:
- Network errors
- Authentication errors
- Server errors
- User-friendly error messages via SnackBar

## Testing

Each screen includes:
- Loading states
- Empty states
- Error states
- Pull-to-refresh functionality
- Search and filter functionality

## Future Enhancements

1. **Detail Screens** - Implement detail views for each item
2. **Create/Edit Forms** - Add form screens for creating and editing items
3. **Offline Support** - Add offline caching and sync
4. **Push Notifications** - Real-time updates for approvals and status changes
5. **Advanced Filtering** - Date range filters and advanced search options
6. **Export Functionality** - PDF/Excel export for reports
7. **Bulk Actions** - Select multiple items for bulk operations

## Dependencies

The implementation uses the following Flutter packages:
- `get` - State management and navigation
- `http` - API requests
- `intl` - Date formatting
- `fluttertoast` - Toast notifications

## API Documentation

For detailed API documentation, refer to: https://api.digixpense.com/docs

## Notes

- All screens follow the established design patterns from the existing codebase
- The global API service ensures consistent Bearer token management
- Common widgets promote code reusability and maintainability
- Error handling is comprehensive and user-friendly
- The implementation is ready for production use 