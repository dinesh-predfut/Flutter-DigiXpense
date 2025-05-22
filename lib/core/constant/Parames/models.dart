class UserProfile {
  final String? accessToken;
  final String? refreshToken;
  final String? email;
  final String? userId;
  final String? employeeId;
  final bool? setUpWidgets;
  final String? userName;
  final int? organizationId;
  final int? subOrganizationId;
  final List<UserSettings>? userSettings;
  final List<OrganizationSettings>? organizationSettings;
  final UserPermissions? userPermissions;
  final List<Role>? roles;
  final String? status;

  UserProfile({
    this.accessToken,
    this.refreshToken,
    this.email,
    this.userId,
    this.employeeId,
    this.setUpWidgets,
    this.userName,
    this.organizationId,
    this.subOrganizationId,
    this.userSettings,
    this.organizationSettings,
    this.userPermissions,
    this.roles,
    this.status,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      accessToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      email: json['Email'] as String?,
      userId: json['UserId'] as String?,
      employeeId: json['EmployeeId'] as String?,
      setUpWidgets: json['SetUpWidgets'] as bool?,
      userName: json['UserName'] as String?,
      organizationId: json['OrganizationId'] as int?,
      subOrganizationId: json['SubOrganizationId'] as int?,
      userSettings: (json['UserSettings'] as List<dynamic>?)
          ?.map((e) => UserSettings.fromJson(e))
          .toList(),
      organizationSettings: (json['OrganizationSettings'] as List<dynamic>?)
          ?.map((e) => OrganizationSettings.fromJson(e))
          .toList(),
      userPermissions: json['UserPermissions'] != null
          ? UserPermissions.fromJson(json['UserPermissions'])
          : null,
      roles: (json['Roles'] as List<dynamic>?)
          ?.map((e) => Role.fromJson(e))
          .toList(),
      status: json['Status'] as String?,
    );
  }
}
class UserSettings {
  final String defaultDateFormat;
  final String defaultCurrency;
  final String defaultTimeZone;
  final String defaultLanguageId;
  final String decimalSeperator;
  final String? defaultPaymentMethodId;
  final bool themeDirection;
  final String themeColor;
  final String defaultTimeZoneValue;
  final bool showAnalyticsOnList;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? profilePicture;
  final String? logo;
  final String? darkLogo;
  final String? favicon;

  UserSettings({
    required this.defaultDateFormat,
    required this.defaultCurrency,
    required this.defaultTimeZone,
    required this.defaultLanguageId,
    required this.decimalSeperator,
    this.defaultPaymentMethodId,
    required this.themeDirection,
    required this.themeColor,
    required this.defaultTimeZoneValue,
    required this.showAnalyticsOnList,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.profilePicture,
    this.logo,
    this.darkLogo,
    this.favicon,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      defaultDateFormat: json['DefaultDateFormat'] as String,
      defaultCurrency: json['DefaultCurrency'] as String,
      defaultTimeZone: json['DefaultTimeZone'] as String,
      defaultLanguageId: json['DefaultLanguageId'] as String,
      decimalSeperator: json['DecimalSeperator'] as String,
      defaultPaymentMethodId: json['DefaultPaymentMethodId'] as String?,
      themeDirection: json['ThemeDirection'] as bool,
      themeColor: json['ThemeColor'] as String,
      defaultTimeZoneValue: json['DefaultTimeZoneValue'].toString(),
      showAnalyticsOnList: json['ShowAnalyticsOnList'] as bool,
      firstName: json['FirstName'] as String,
      middleName: json['MiddleName'] as String?,
      lastName: json['LastName'] as String,
      profilePicture: json['ProfilePicture'] as String?,
      logo: json['Logo'] as String?,
      darkLogo: json['DarkLogo'] as String?,
      favicon: json['Favicon'] as String?,
    );
  }
}
class OrganizationSettings {
  final String? taxGroupId;
  final String? exchangeRateProvider;
  final String? allowDomains;
  final bool enableProject;
  final bool enableUserDelegate;
  final int numberOfDecimal;
  final bool allowThemesSettings;
  final String organizationDefaultCurrency;
  final String orgDefaultLanguageId;
  final String orgDecimalSeperator;
  final String organizationDefaultCurrencySymbol;
  final bool organizationEnablePerdiem;
  final bool organizationEnableMileage;
  final String organizationDefaultMileagUnit;

  OrganizationSettings({
    this.taxGroupId,
    this.exchangeRateProvider,
    this.allowDomains,
    required this.enableProject,
    required this.enableUserDelegate,
    required this.numberOfDecimal,
    required this.allowThemesSettings,
    required this.organizationDefaultCurrency,
    required this.orgDefaultLanguageId,
    required this.orgDecimalSeperator,
    required this.organizationDefaultCurrencySymbol,
    required this.organizationEnablePerdiem,
    required this.organizationEnableMileage,
    required this.organizationDefaultMileagUnit,
  });

  factory OrganizationSettings.fromJson(Map<String, dynamic> json) {
    return OrganizationSettings(
      taxGroupId: json['TaxGroupId'] as String?,
      exchangeRateProvider: json['ExchangeRateProvider'] as String?,
      allowDomains: json['AllowDomains'] as String?,
      enableProject: json['EnableProject'] as bool,
      enableUserDelegate: json['EnableUserDelegate'] as bool,
      numberOfDecimal: json['NumberOfDecimal'] as int,
      allowThemesSettings: json['AllowThemesSettings'] as bool,
      organizationDefaultCurrency:
          json['OrganizationDefaultCurrency'] as String,
      orgDefaultLanguageId: json['OrgDefaultLanguageId'] as String,
      orgDecimalSeperator: json['OrgDecimalSeperator'] as String,
      organizationDefaultCurrencySymbol:
          json['OrganizationDefaultCurrencySymbol'] as String,
      organizationEnablePerdiem: json['OrganizationEnablePerdiem'] as bool,
      organizationEnableMileage: json['OrganizationEnableMileage'] as bool,
      organizationDefaultMileagUnit:
          json['OrganizationDefaultMileagUnit'] as String,
    );
  }
}
class UserPermissions {
  final List<String> read;
  final List<String> write;
  final List<String> update;
  final List<String> delete;

  UserPermissions({
    required this.read,
    required this.write,
    required this.update,
    required this.delete,
  });

  factory UserPermissions.fromJson(Map<String, dynamic> json) {
    return UserPermissions(
      read: List<String>.from(json['Read']),
      write: List<String>.from(json['Write']),
      update: List<String>.from(json['Update']),
      delete: List<String>.from(json['Delete']),
    );
  }
}
class Role {
  final String? roleId;
  final String? roleName;

  Role({
    this.roleId,
    this.roleName,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      roleId: json['RoleId'] as String?,
      roleName: json['RoleName'] as String?,
    );
  }
}
