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
  final String? name;
  final String? value;
  final String? defaultValue;
  final String? displayName;

  UserSettings({
    this.name,
    this.value,
    this.defaultValue,
    this.displayName,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        name: json['Name'] as String?,
        value: json['Value'] as String?,
        defaultValue: json['DefaultValue'] as String?,
        displayName: json['DisplayName'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'Name': name,
        'Value': value,
        'DefaultValue': defaultValue,
        'DisplayName': displayName,
      };
}
class OrganizationSettings {
  final String? name;
  final String? value;
  final String? defaultValue;
  final String? displayName;
  final String? organizationDefaultMileagUnit;

  OrganizationSettings({
    this.name,
    this.value,
    this.defaultValue,
    this.displayName,
    this.organizationDefaultMileagUnit,
  });

  factory OrganizationSettings.fromJson(Map<String, dynamic> json) =>
      OrganizationSettings(
        name: json['Name'] as String?,
        value: json['Value'] as String?,
        defaultValue: json['DefaultValue'] as String?,
        displayName: json['DisplayName'] as String?,
        organizationDefaultMileagUnit:
            json['OrganizationDefaultMileageUnit'] as String? ??
                json['OrganizationDefaultMileagUnit'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'Name': name,
        'Value': value,
        'DefaultValue': defaultValue,
        'DisplayName': displayName,
        'OrganizationDefaultMileagUnit': organizationDefaultMileagUnit,
      };
}


class UserPermissions {
  final List<String>? read;
  final List<String>? write;
  final List<String>? update;
  final List<String>? delete;

  UserPermissions({
    this.read,
    this.write,
    this.update,
    this.delete,
  });

  factory UserPermissions.fromJson(Map<String, dynamic> json) =>
      UserPermissions(
        read: List<String>.from(json['Read'] ?? []),
        write: List<String>.from(json['Write'] ?? []),
        update: List<String>.from(json['Update'] ?? []),
        delete: List<String>.from(json['Delete'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'Read': read,
        'Write': write,
        'Update': update,
        'Delete': delete,
      };
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
